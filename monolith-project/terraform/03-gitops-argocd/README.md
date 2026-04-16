# 03-gitops-argocd (Argo CD)

This module installs Argo CD on the EKS cluster from `terraform/02-k8s-platform` and can optionally bootstrap an Argo CD `Application` resource.

## What It Creates

- Argo CD namespace
- Argo CD Helm release
- Optional workload namespace
- Optional Argo CD Application for auto-sync

## Dependency

This module reads remote state outputs from `terraform/02-k8s-platform`.

Apply `terraform/02-k8s-platform` first, with remote state in S3.

## Usage

1. Configure `backend.hcl` and `terraform.tfvars` from examples.
2. Set `gitops_repo_url` to this repository URL.
3. Keep `gitops_app_path = "terraform/03-gitops-argocd/gitops/apps/project1"`.
4. Replace placeholders in manifests:
   - `deployment.yaml`: `REPLACE_WITH_RDS_ENDPOINT` from `terraform/01-core-infra` output `rds_endpoint`
   - `externalsecret.yaml`: `REPLACE_WITH_DB_SECRET_ARN` from `terraform/01-core-infra` output `db_secret_arn`
5. Ensure External Secrets Operator is installed and `ClusterSecretStore` named `aws-secretsmanager` exists.

Then run:

```bash
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

## Autoscaling

The GitOps app manifest includes a HorizontalPodAutoscaler:

- file: `gitops/apps/project1/hpa.yaml`
- min replicas: `2`
- max replicas: `8`
- CPU target: `60%`

Deployment manifest also includes CPU/memory requests and limits so HPA can make scaling decisions reliably.

## Hardening Notes

- DB password is sourced from AWS Secrets Manager via `ExternalSecret` instead of committing a Kubernetes Secret value in Git.
- Deployment uses pod/container security context defaults suitable for non-root runtime.
