# 02-k8s-platform (EKS + ECR)

This module provisions Kubernetes platform resources used by workloads from `terraform/01-core-infra`.

## What It Creates

- Amazon EKS cluster
- EKS control-plane logging to CloudWatch
- Managed node group in core-infra private subnets
- ECR repository for application images
- ECR lifecycle policy
- Optional GitHub OIDC IAM role for least-privilege ECR push from Actions

## Dependency

This module reads remote state outputs from `terraform/01-core-infra`:

- `vpc_id`
- `private_subnet_ids`

Apply `terraform/01-core-infra` first, with remote state in S3.

## Logging Controls

- `cluster_enabled_log_types` controls which EKS control-plane logs are enabled.
- `eks_control_plane_log_retention_days` sets retention for `/aws/eks/<cluster>/cluster`.

## Usage

```bash
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

## Key Output For CI

Use `github_actions_role_arn` as repository variable `AWS_ROLE_TO_ASSUME`.

## Notes

For production hardening, add tighter IAM policies, private endpoint access strategy, KMS controls, and workload-specific IRSA roles.
