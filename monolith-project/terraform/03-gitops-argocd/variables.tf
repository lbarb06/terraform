variable "aws_region" {
  description = "AWS region to deploy GitOps resources in"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Named AWS CLI profile to use for deployments"
  type        = string
  default     = "admin"
}

variable "project_name" {
  description = "Project name prefix for GitOps resources"
  type        = string
  default     = "project1-gitops"
}

variable "environment" {
  description = "Environment label for GitOps resources"
  type        = string
  default     = "main"
}

variable "project_4_state_bucket" {
  description = "S3 bucket that stores 02-k8s-platform Terraform state"
  type        = string
}

variable "project_4_state_key" {
  description = "S3 object key for 02-k8s-platform Terraform state"
  type        = string
  default     = "project4/main/terraform.tfstate"
}

variable "project_4_state_region" {
  description = "AWS region of the 02-k8s-platform Terraform state bucket"
  type        = string
  default     = "us-east-1"
}

variable "argocd_namespace" {
  description = "Namespace where Argo CD will be installed"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "7.7.16"
}

variable "create_ingress" {
  description = "Enable Argo CD server ingress"
  type        = bool
  default     = false
}

variable "argocd_hostname" {
  description = "Hostname for Argo CD ingress (required if create_ingress=true)"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = !var.create_ingress || var.argocd_hostname != null
    error_message = "argocd_hostname must be set when create_ingress is true."
  }
}

variable "bootstrap_application" {
  description = "Create an Argo CD Application resource for your workload repo"
  type        = bool
  default     = false
}

variable "gitops_repo_url" {
  description = "Git repository URL for GitOps manifests"
  type        = string
  default     = null
  nullable    = true
}

variable "gitops_repo_branch" {
  description = "Git branch for GitOps manifests"
  type        = string
  default     = "main"
}

variable "gitops_app_path" {
  description = "Path inside the Git repo where Kubernetes manifests live"
  type        = string
  default     = "terraform/03-gitops-argocd/gitops/apps/project1"
}

variable "gitops_destination_namespace" {
  description = "Namespace Argo CD deploys the workload into"
  type        = string
  default     = "project1"
}
