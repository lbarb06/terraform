variable "aws_region" {
  description = "AWS region to deploy observability resources in"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Named AWS CLI profile to use for deployments"
  type        = string
  default     = "admin"
}

variable "project_name" {
  description = "Project name prefix for observability resources"
  type        = string
  default     = "project1-observability"
}

variable "environment" {
  description = "Environment label for observability resources"
  type        = string
  default     = "main"
}

variable "project_1_state_bucket" {
  description = "S3 bucket that stores 01-core-infra Terraform state"
  type        = string
}

variable "project_1_state_key" {
  description = "S3 object key for 01-core-infra Terraform state"
  type        = string
  default     = "project1/main/terraform.tfstate"
}

variable "project_1_state_region" {
  description = "AWS region of the 01-core-infra Terraform state bucket"
  type        = string
  default     = "us-east-1"
}

variable "alarm_email" {
  description = "Optional email address that receives alarm notifications"
  type        = string
  default     = null
  nullable    = true
}

variable "alarm_actions_enabled" {
  description = "Enable SNS actions on CloudWatch alarms"
  type        = bool
  default     = true
}

variable "alb_5xx_threshold" {
  description = "Threshold for ALB 5xx errors during a 5-minute period"
  type        = number
  default     = 5
}

variable "alb_target_response_time_threshold" {
  description = "Threshold in seconds for average ALB target response time"
  type        = number
  default     = 1
}

variable "unhealthy_host_threshold" {
  description = "Threshold for unhealthy target count"
  type        = number
  default     = 1
}

variable "asg_in_service_threshold" {
  description = "Minimum healthy in-service instance count before alarming"
  type        = number
  default     = 1
}

variable "rds_cpu_threshold" {
  description = "Threshold for RDS CPU utilization percentage"
  type        = number
  default     = 80
}

variable "rds_free_storage_threshold_bytes" {
  description = "Threshold for low free RDS storage in bytes"
  type        = number
  default     = 2147483648
}
