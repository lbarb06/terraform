locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_s3_bucket" "artifacts" {
  bucket = var.artifact_bucket_name
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "codebuild" {
  name = "${local.name_prefix}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_deploy" {
  role       = aws_iam_role.codebuild.name
  policy_arn = var.deployment_policy_arn
}

resource "aws_iam_role_policy" "codebuild_inline" {
  name = "${local.name_prefix}-codebuild-inline"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*",
          "arn:aws:s3:::${var.project_1_state_bucket}",
          "arn:aws:s3:::${var.project_1_state_bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "codepipeline" {
  name = "${local.name_prefix}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline_inline" {
  name = "${local.name_prefix}-codepipeline-inline"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = [
          aws_codebuild_project.plan.arn,
          aws_codebuild_project.apply.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = var.codestar_connection_arn
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = var.enable_manual_approval ? aws_sns_topic.pipeline_approvals[0].arn : "*"
      }
    ]
  })
}

resource "aws_sns_topic" "pipeline_approvals" {
  count = var.enable_manual_approval ? 1 : 0
  name  = "${local.name_prefix}-approvals"
}

resource "aws_sns_topic_subscription" "pipeline_approvals_email" {
  count     = var.enable_manual_approval && var.notification_email != null ? 1 : 0
  topic_arn = aws_sns_topic.pipeline_approvals[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_codebuild_project" "plan" {
  name         = "${local.name_prefix}-plan"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.build_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_ROOT"
      value = var.project_1_directory
    }

    environment_variable {
      name  = "TF_VAR_FILE"
      value = var.project_1_var_file
    }

    environment_variable {
      name  = "TF_STATE_BUCKET"
      value = var.project_1_state_bucket
    }

    environment_variable {
      name  = "TF_STATE_KEY"
      value = var.project_1_state_key
    }

    environment_variable {
      name  = "TF_STATE_REGION"
      value = var.project_1_state_region
    }

    environment_variable {
      name  = "TF_VERSION"
      value = var.terraform_version
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspecs/plan.yml")
  }
}

resource "aws_codebuild_project" "apply" {
  name         = "${local.name_prefix}-apply"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.build_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_ROOT"
      value = var.project_1_directory
    }

    environment_variable {
      name  = "TF_VAR_FILE"
      value = var.project_1_var_file
    }

    environment_variable {
      name  = "TF_STATE_BUCKET"
      value = var.project_1_state_bucket
    }

    environment_variable {
      name  = "TF_STATE_KEY"
      value = var.project_1_state_key
    }

    environment_variable {
      name  = "TF_STATE_REGION"
      value = var.project_1_state_region
    }

    environment_variable {
      name  = "TF_VERSION"
      value = var.terraform_version
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspecs/apply.yml")
  }
}

resource "aws_codepipeline" "project_1" {
  name     = "${local.name_prefix}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = var.repository_full_name
        BranchName       = var.repository_branch
      }
    }
  }

  stage {
    name = "Plan"

    action {
      name             = "TerraformPlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["plan_output"]

      configuration = {
        ProjectName = aws_codebuild_project.plan.name
      }
    }
  }

  dynamic "stage" {
    for_each = var.enable_manual_approval ? [1] : []

    content {
      name = "Approval"

      action {
        name            = "ApprovePlan"
        category        = "Approval"
        owner           = "AWS"
        provider        = "Manual"
        version         = "1"
        input_artifacts = ["plan_output"]

        configuration = {
          NotificationArn = aws_sns_topic.pipeline_approvals[0].arn
          CustomData      = "Review the Terraform plan output before allowing apply."
        }
      }
    }
  }

  stage {
    name = "Apply"

    action {
      name            = "TerraformApply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.apply.name
      }
    }
  }
}
