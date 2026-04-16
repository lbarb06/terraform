variable "aws_region" {
  description = "AWS region to deploy Kubernetes platform resources in"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Named AWS CLI profile to use for deployments"
  type        = string
  default     = "admin"
}

variable "project_name" {
  description = "Project name prefix for Kubernetes resources"
  type        = string
  default     = "project1-k8s"
}

variable "environment" {
  description = "Environment label for Kubernetes resources"
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

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "cluster_enabled_log_types" {
  description = "EKS control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "eks_control_plane_log_retention_days" {
  description = "Retention period for EKS control plane logs"
  type        = number
  default     = 14
}

variable "node_instance_types" {
  description = "EC2 instance types for managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "disk_size_gb" {
  description = "Disk size for worker nodes"
  type        = number
  default     = 30
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository for container images"
  type        = string
  default     = "project1-webapp"
}

variable "ecr_image_tag_mutability" {
  description = "ECR image tag mutability setting (IMMUTABLE recommended)"
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["IMMUTABLE", "MUTABLE"], var.ecr_image_tag_mutability)
    error_message = "ecr_image_tag_mutability must be IMMUTABLE or MUTABLE."
  }
}

variable "enable_github_oidc_role" {
  description = "Create IAM OIDC provider and role for GitHub Actions ECR push"
  type        = bool
  default     = true
}

variable "github_repository" {
  description = "GitHub repository in owner/repo format allowed to assume the OIDC role"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = !var.enable_github_oidc_role || var.github_repository != null
    error_message = "github_repository must be set when enable_github_oidc_role is true."
  }
}

variable "github_oidc_branch" {
  description = "Git branch allowed to assume the OIDC role"
  type        = string
  default     = "main"
}
