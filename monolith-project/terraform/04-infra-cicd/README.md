# 05-infra-cicd (CodePipeline + CodeBuild)

This module provisions AWS-native CI/CD infrastructure for Terraform workflows.

## What It Creates

- Artifact S3 bucket
- CodeBuild project for `terraform plan`
- CodeBuild project for `terraform apply`
- CodePipeline with source, plan, optional approval, and apply stages
- Optional SNS topic and email subscription for approval notifications

## Intended Flow

1. Commit lands in the configured repository branch.
2. CodePipeline pulls source via CodeStar connection.
3. CodeBuild runs `fmt`, `init`, `validate`, and `plan` against `terraform/01-core-infra`.
4. Optional manual approval gate pauses execution.
5. CodeBuild applies core infrastructure after approval.

## Prerequisites

- Source repository includes `terraform/01-core-infra`
- CodeStar connection already created and authorized
- Remote backend for `terraform/01-core-infra` is already configured

## Usage

```bash
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```
