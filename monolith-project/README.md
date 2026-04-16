# Terraform Portfolio Monorepo

This repository is organized as a single monorepo for infrastructure, application code, CI/CD, Kubernetes operations, and QA assets.

## Repository Layout

- `terraform/01-core-infra`: VPC, ALB, ASG, RDS, Secrets Manager, optional Route53
- `terraform/02-k8s-platform`: EKS, ECR, GitHub OIDC role for CI image push
- `terraform/03-gitops-argocd`: Argo CD install and GitOps app bootstrap
- `archive/2026-04-cleanup/04-observability (archived)`: CloudWatch dashboards and alarms
- `terraform/04-infra-cicd`: AWS CodePipeline/CodeBuild for Terraform workflows
- `apps/webapp`: Node.js webapp with unit and UI tests
- `qa/`: test suites and shared test data
- `kubernetes/`: runbooks, troubleshooting notes, and incident drills
- `ci-cd/`: additional CI/CD assets (GitHub Actions and Jenkins)
- `docs/`: architecture and onboarding documentation

## Recommended Apply Order

1. `terraform/01-core-infra`
2. `terraform/02-k8s-platform`
3. `terraform/03-gitops-argocd`
4. `archive/2026-04-cleanup/04-observability (archived)`
5. `terraform/04-infra-cicd`

## App Delivery Flow

1. Commit changes under `apps/webapp/`.
2. `.github/workflows/webapp-cicd.yml` runs unit and UI tests.
3. Workflow assumes AWS role via OIDC (no static AWS keys).
4. Docker image is built and pushed to ECR.
5. Workflow updates `terraform/03-gitops-argocd/gitops/apps/project1/deployment.yaml` image tag.
6. Argo CD syncs manifests to EKS.
7. Optional deployed UI tests validate runtime behavior and `/version`.

## Security Hardening Defaults

- DB master password is auto-generated and stored in AWS Secrets Manager.
- GitOps app consumes DB secret through `ExternalSecret` (no DB password in Git).
- ALB supports optional HTTPS with ACM (`enable_https`, `acm_certificate_arn`, `redirect_http_to_https`).
- ECR tag mutability defaults to `IMMUTABLE`.
- Webapp deployment runs as non-root with seccomp/capability restrictions.

## Messages API Quickstart

Run the app locally:

```bash
cd apps/webapp
npm install
npm start
```

Check backend/DB status:

```bash
curl http://127.0.0.1:3000/api/backend
```

Create a message:

```bash
curl -X POST http://127.0.0.1:3000/api/messages \
  -H "Content-Type: application/json" \
  -d '{"content":"hello from api"}'
```

List messages:

```bash
curl http://127.0.0.1:3000/api/messages
```

Example responses:

```json
{
  "version": "dev",
  "db": {
    "configured": true,
    "connected": true,
    "error": null
  }
}
```
Response for `POST /api/messages`:

```json
{
  "message": {
    "id": 1,
    "content": "hello from api"
  }
}
```
Response for `GET /api/messages`:

```json
{
  "messages": [
    {
      "id": 1,
      "content": "hello from api",
      "createdAt": "2026-04-02T21:20:00.000Z"
    }
  ]
}
```

Notes:

- When DB env vars are not configured, message endpoints return `503`.
- UI at `/` also submits and lists messages through the same API.

## GitHub Settings Required

Repository variables:

- `AWS_REGION` (example: `us-east-1`)
- `AWS_ROLE_TO_ASSUME` (output `github_actions_role_arn` from `terraform/02-k8s-platform`)
- `RUN_DEPLOYED_UI_TESTS` (`true` or `false`)

Repository secrets:

- `ECR_REPOSITORY_URL` (output `ecr_repository_url` from `terraform/02-k8s-platform`)
- `WEBAPP_BASE_URL` (only if deployed UI tests are enabled)

## End-To-End Bring-Up

### 1) Deploy core infrastructure

```bash
cd terraform/01-core-infra
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl
terraform apply
```

Capture outputs:

- `rds_endpoint`
- `db_secret_arn`
- `db_name`
- `db_username`

### 2) Deploy Kubernetes platform

```bash
cd ../02-k8s-platform
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl
terraform apply
```

Capture outputs:

- `ecr_repository_url`
- `github_actions_role_arn`

### 3) Deploy GitOps bootstrap

```bash
cd ../03-gitops-argocd
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl
terraform apply
```

### 4) Wire DB runtime values into app manifest

Update `terraform/03-gitops-argocd/gitops/apps/project1/deployment.yaml`:

- Replace `REPLACE_WITH_RDS_ENDPOINT` with `rds_endpoint` from `terraform/01-core-infra`
- Replace `REPLACE_WITH_DB_SECRET_ARN` in `externalsecret.yaml` with `db_secret_arn` from `terraform/01-core-infra`

Note: install External Secrets Operator and create a `ClusterSecretStore` named `aws-secretsmanager` so the app secret is synced from AWS Secrets Manager.

### 5) Push application change to deploy

Push to `main` with changes under `apps/webapp/` and let the workflow build, publish, and roll out through GitOps.
