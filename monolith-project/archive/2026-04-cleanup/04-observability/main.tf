data "terraform_remote_state" "project_1" {
  backend = "s3"

  config = {
    bucket  = var.project_1_state_bucket
    key     = var.project_1_state_key
    region  = var.project_1_state_region
    profile = var.aws_profile
  }
}

locals {
  name_prefix       = "${var.project_name}-${var.environment}"
  alarm_actions     = var.alarm_actions_enabled && var.alarm_email != null ? [aws_sns_topic.alerts[0].arn] : []
  ec2_app_log_group = try(data.terraform_remote_state.project_1.outputs.ec2_app_log_group_name, null)
}

resource "aws_sns_topic" "alerts" {
  count = var.alarm_email != null ? 1 : 0
  name  = "${local.name_prefix}-alerts"
}

resource "aws_sns_topic_subscription" "alerts_email" {
  count     = var.alarm_email != null ? 1 : 0
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${local.name_prefix}-alb-5xx"
  alarm_description   = "High rate of ALB 5xx responses"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = var.alb_5xx_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions

  dimensions = {
    LoadBalancer = data.terraform_remote_state.project_1.outputs.alb_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_response_time" {
  alarm_name          = "${local.name_prefix}-alb-response-time"
  alarm_description   = "Average ALB target response time is too high"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "TargetResponseTime"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.alb_target_response_time_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions

  dimensions = {
    LoadBalancer = data.terraform_remote_state.project_1.outputs.alb_arn_suffix
    TargetGroup  = data.terraform_remote_state.project_1.outputs.target_group_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${local.name_prefix}-alb-unhealthy-hosts"
  alarm_description   = "Target group has unhealthy hosts"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = var.unhealthy_host_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions

  dimensions = {
    LoadBalancer = data.terraform_remote_state.project_1.outputs.alb_arn_suffix
    TargetGroup  = data.terraform_remote_state.project_1.outputs.target_group_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "asg_in_service" {
  alarm_name          = "${local.name_prefix}-asg-in-service"
  alarm_description   = "Auto Scaling Group has too few healthy instances"
  namespace           = "AWS/AutoScaling"
  metric_name         = "GroupInServiceInstances"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = var.asg_in_service_threshold
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions

  dimensions = {
    AutoScalingGroupName = data.terraform_remote_state.project_1.outputs.asg_name
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${local.name_prefix}-rds-cpu"
  alarm_description   = "RDS CPU utilization is too high"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.rds_cpu_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions

  dimensions = {
    DBInstanceIdentifier = data.terraform_remote_state.project_1.outputs.rds_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
  alarm_name          = "${local.name_prefix}-rds-free-storage"
  alarm_description   = "RDS free storage is running low"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.rds_free_storage_threshold_bytes
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions

  dimensions = {
    DBInstanceIdentifier = data.terraform_remote_state.project_1.outputs.rds_identifier
  }
}

resource "aws_cloudwatch_dashboard" "project_1" {
  dashboard_name = "${local.name_prefix}-dashboard"
  dashboard_body = jsonencode({
    widgets = concat(
      [
        {
          type   = "metric"
          width  = 12
          height = 6
          properties = {
            title   = "ALB Target Response Time"
            region  = var.aws_region
            view    = "timeSeries"
            stat    = "Average"
            period  = 300
            metrics = [["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", data.terraform_remote_state.project_1.outputs.alb_arn_suffix, "TargetGroup", data.terraform_remote_state.project_1.outputs.target_group_arn_suffix]]
          }
        },
        {
          type   = "metric"
          width  = 12
          height = 6
          properties = {
            title   = "ALB 5xx Errors"
            region  = var.aws_region
            view    = "timeSeries"
            stat    = "Sum"
            period  = 300
            metrics = [["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", data.terraform_remote_state.project_1.outputs.alb_arn_suffix]]
          }
        },
        {
          type   = "metric"
          width  = 12
          height = 6
          properties = {
            title   = "ASG In-Service Instances"
            region  = var.aws_region
            view    = "timeSeries"
            stat    = "Average"
            period  = 60
            metrics = [["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", data.terraform_remote_state.project_1.outputs.asg_name]]
          }
        },
        {
          type   = "metric"
          width  = 12
          height = 6
          properties = {
            title   = "RDS CPU Utilization"
            region  = var.aws_region
            view    = "timeSeries"
            stat    = "Average"
            period  = 300
            metrics = [["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", data.terraform_remote_state.project_1.outputs.rds_identifier]]
          }
        }
      ],
      local.ec2_app_log_group != null ? [
        {
          type   = "log"
          width  = 24
          height = 6
          properties = {
            title  = "EC2 App Errors (Logs Insights)"
            region = var.aws_region
            query  = "SOURCE '${local.ec2_app_log_group}' | filter @message like /error|ERROR|Error|5\\d\\d/ | sort @timestamp desc | limit 100"
            view   = "table"
          }
        }
      ] : []
    )
  })
}
