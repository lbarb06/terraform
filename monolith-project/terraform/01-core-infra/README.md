# 01-core-infra (AWS Web Stack)

This module deploys a production-style web infrastructure baseline on AWS.

## What It Creates

- VPC with public/private subnets across 2 AZs
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG) for EC2 web instances
- RDS MySQL in private subnets
- Secrets Manager secret for generated DB credentials
- CloudWatch log group + EC2 CloudWatch Agent log shipping (nginx/system logs)
- Optional Route53 record pointing to the ALB

## Files

- `versions.tf`: Terraform and provider constraints
- `backend.hcl.example`: Example S3 backend configuration
- `provider.tf`: AWS provider configuration and tags
- `variables.tf`: Input variables
- `main.tf`: Core infrastructure resources
- `outputs.tf`: Useful outputs
- `scripts/user_data.sh`: EC2 bootstrap and log agent configuration
- `terraform.tfvars.example`: Example runtime values

## Prerequisites

- Terraform >= 1.5
- AWS credentials configured (`AWS_PROFILE` or environment variables)
- Public Route53 hosted zone only if DNS record creation is enabled

## Target A Specific AWS Account

1. Set `aws_profile` in `terraform.tfvars`.
2. Verify it maps to the intended account:

```bash
aws sts get-caller-identity --profile <your-profile-name>
```

## Remote State

Use an S3 backend for Terraform state.

1. Create an S3 bucket for state.
2. Copy `backend.hcl.example` to `backend.hcl`.
3. Fill in bucket, key, region, and profile.
4. Initialize Terraform:

```bash
terraform init -backend-config=backend.hcl
```

If migrating existing local state:

```bash
terraform init -backend-config=backend.hcl -migrate-state
```

## DNS Options

- If you do not have a domain yet, set `create_dns_record = false` and use the ALB DNS output.
- If you have Route53 hosted zone, set `create_dns_record = true` and provide:
  - `domain_name`
  - `route53_zone_name`

## Logging Options

- `enable_ec2_log_shipping = true` installs/configures CloudWatch Agent on EC2 instances.
- `ec2_log_retention_days` controls retention in the app log group.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

## Cleanup

```bash
terraform destroy
```

## Notes

- DB password is auto-generated and stored in Secrets Manager.
- Secret values are still represented in Terraform state, so use protected remote state.
- `backend.hcl` is gitignored so backend/account details remain local.

## Related Modules

- `terraform/02-k8s-platform`: EKS + ECR + GitHub OIDC
- `terraform/03-gitops-argocd`: Argo CD bootstrap for EKS
- `archive/2026-04-cleanup/04-observability (archived)`: CloudWatch dashboards and alarms
- `terraform/04-infra-cicd`: CodePipeline/CodeBuild for infra workflows

## Recommended Apply Order

1. `terraform/01-core-infra`
2. `terraform/02-k8s-platform`
3. `terraform/03-gitops-argocd`
4. `archive/2026-04-cleanup/04-observability (archived)`
5. `terraform/04-infra-cicd`
