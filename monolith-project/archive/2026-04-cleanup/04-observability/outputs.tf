output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.project_1.dashboard_name
}

output "alarm_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  value       = var.alarm_email != null ? aws_sns_topic.alerts[0].arn : null
}
