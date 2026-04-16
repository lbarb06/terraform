output "artifact_bucket_name" {
  description = "S3 bucket used by CodePipeline for artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}

output "pipeline_name" {
  description = "Name of the CodePipeline pipeline"
  value       = aws_codepipeline.project_1.name
}

output "plan_project_name" {
  description = "Name of the CodeBuild project used for terraform plan"
  value       = aws_codebuild_project.plan.name
}

output "apply_project_name" {
  description = "Name of the CodeBuild project used for terraform apply"
  value       = aws_codebuild_project.apply.name
}

output "approval_topic_arn" {
  description = "SNS topic ARN for pipeline approval notifications"
  value       = var.enable_manual_approval ? aws_sns_topic.pipeline_approvals[0].arn : null
}
