output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for workloads such as EKS nodes"
  value       = [for s in aws_subnet.private : s.id]
}

output "public_subnet_ids" {
  description = "Public subnet IDs for internet-reachable workloads"
  value       = [for s in aws_subnet.public : s.id]
}

output "alb_dns_name" {
  description = "Public DNS name of the load balancer"
  value       = aws_lb.app.dns_name
}

output "alb_arn" {
  description = "ARN of the application load balancer"
  value       = aws_lb.app.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of the application load balancer for CloudWatch dimensions"
  value       = aws_lb.app.arn_suffix
}

output "application_url" {
  description = "Application URL (custom domain if DNS enabled, otherwise ALB DNS; HTTPS if enabled)"
  value = format(
    "%s://%s",
    var.enable_https && var.acm_certificate_arn != null ? "https" : "http",
    var.create_dns_record && var.domain_name != null ? var.domain_name : aws_lb.app.dns_name
  )
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener when enabled"
  value       = var.enable_https && var.acm_certificate_arn != null ? aws_lb_listener.https[0].arn : null
}

output "target_group_arn" {
  description = "ARN of the load balancer target group"
  value       = aws_lb_target_group.app.arn
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the load balancer target group for CloudWatch dimensions"
  value       = aws_lb_target_group.app.arn_suffix
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.app.address
}

output "rds_identifier" {
  description = "Identifier of the RDS instance"
  value       = aws_db_instance.app.identifier
}

output "rds_security_group_id" {
  value = aws_security_group.db.id
}

output "db_name" {
  description = "Configured database name used by the application"
  value       = var.db_name
}

output "db_username" {
  description = "Configured database username used by the application"
  value       = var.db_username
}

output "db_secret_arn" {
  description = "Secrets Manager ARN containing the generated database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.app.name
}

output "ec2_app_log_group_name" {
  description = "CloudWatch log group used by EC2 app instances"
  value       = var.enable_ec2_log_shipping ? aws_cloudwatch_log_group.app_ec2[0].name : null
}

output "project_label" {
  description = "Project label used by downstream Terraform projects"
  value       = var.project_name
}

output "environment_label" {
  description = "Environment label used by downstream Terraform projects"
  value       = var.environment
}
