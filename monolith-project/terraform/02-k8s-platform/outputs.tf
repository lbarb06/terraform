output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_control_plane_log_group_name" {
  description = "CloudWatch log group name for EKS control plane logs"
  value       = aws_cloudwatch_log_group.eks_control_plane.name
}

output "node_group_name" {
  description = "Managed node group name"
  value       = aws_eks_node_group.main.node_group_name
}

output "ecr_repository_name" {
  description = "ECR repository name for application images"
  value       = aws_ecr_repository.webapp.name
}

output "ecr_repository_url" {
  description = "ECR repository URL for docker push/pull"
  value       = aws_ecr_repository.webapp.repository_url
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC ECR push workflow"
  value       = var.enable_github_oidc_role ? aws_iam_role.github_actions_ecr[0].arn : null
}
