variable "aws_region" {
  description = "AWS region to deploy CI/CD resources in"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Named AWS CLI profile to use for deployments"
  type        = string
  default     = "admin"
}

variable "project_name" {
  description = "Project name prefix for CI/CD resources"
  type        = string
  default     = "project1-cicd"
}

variable "environment" {
  description = "Environment label for CI/CD resources"
  type        = string
  default     = "main"
}

variable "artifact_bucket_name" {
  description = "Globally unique S3 bucket name for CodePipeline artifacts"
  type        = string
}

variable "repository_full_name" {
  description = "Source repository in owner/repo format"
  type        = string
}

variable "repository_branch" {
  description = "Repository branch to deploy from"
  type        = string
  default     = "main"
}

variable "codestar_connection_arn" {
  description = "ARN of the AWS CodeStar connection to the source repository"
  type        = string
}

variable "project_1_directory" {
  description = "Path to 01-core-infra Terraform root inside the source repository"
  type        = string
  default     = "terraform/01-core-infra"
}

variable "project_1_var_file" {
  description = "Terraform variable file for 01-core-infra used by the pipeline"
  type        = string
  default     = "terraform.tfvars"
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

variable "terraform_version" {
  description = "Terraform version installed in CodeBuild"
  type        = string
  default     = "1.9.8"
}

variable "build_image" {
  description = "CodeBuild image used for plan and apply"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "enable_manual_approval" {
  description = "Require manual approval between plan and apply"
  type        = bool
  default     = true
}

variable "notification_email" {
  description = "Optional email address for pipeline approval notifications"
  type        = string
  default     = null
  nullable    = true
}

variable "deployment_policy_arn" {
  description = "IAM policy attached to the CodeBuild deployment role"
  type        = string
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
}
