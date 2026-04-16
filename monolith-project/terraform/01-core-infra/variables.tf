variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Named AWS CLI profile to use for deployments (maps to a specific AWS account)"
  type        = string
  default     = "default"
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "webapp"
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks (2 AZs recommended)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks for app and DB"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type for app servers"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Auto Scaling Group minimum size"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Auto Scaling Group maximum size"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Auto Scaling Group desired capacity"
  type        = number
  default     = 2
}

variable "app_port" {
  description = "Application port exposed on EC2 instances"
  type        = number
  default     = 80
}

variable "db_engine_version" {
  description = "MySQL engine version for RDS"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master DB username"
  type        = string
  default     = "appadmin"
}

variable "create_dns_record" {
  description = "Create a Route53 alias record for the application"
  type        = bool
  default     = false

  validation {
    condition     = !var.create_dns_record || (var.domain_name != null && var.route53_zone_name != null)
    error_message = "When create_dns_record is true, both domain_name and route53_zone_name must be set."
  }
}

variable "domain_name" {
  description = "FQDN for application (e.g. app.example.com). Required only when create_dns_record=true."
  type        = string
  default     = null
  nullable    = true
}

variable "route53_zone_name" {
  description = "Route53 hosted zone name (e.g. example.com.). Required only when create_dns_record=true."
  type        = string
  default     = null
  nullable    = true
}

variable "enable_https" {
  description = "Enable HTTPS listener on ALB using ACM certificate"
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_https || var.acm_certificate_arn != null
    error_message = "acm_certificate_arn must be set when enable_https is true."
  }
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for ALB HTTPS listener (required when enable_https=true)"
  type        = string
  default     = null
  nullable    = true
}

variable "redirect_http_to_https" {
  description = "Redirect HTTP traffic to HTTPS when HTTPS is enabled"
  type        = bool
  default     = true
}

variable "enable_multi_az_db" {
  description = "Enable Multi-AZ deployment for RDS"
  type        = bool
  default     = false
}

variable "enable_ec2_log_shipping" {
  description = "Install and configure CloudWatch Agent on app EC2 instances"
  type        = bool
  default     = true
}

variable "ec2_log_retention_days" {
  description = "Retention period for EC2 app/system logs in CloudWatch"
  type        = number
  default     = 14
}
