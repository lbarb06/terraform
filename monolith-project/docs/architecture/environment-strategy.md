# Environment Strategy

## Goal

Define how environments are separated and promoted while keeping Terraform and app deployment manageable.

## Recommended Environments

- `dev`: fast iteration and integration checks
- `qa`: test validation and regression checks
- `uat`: business validation and release candidate checks
- `prod`: customer-facing stable environment

## Terraform Strategy

Option A (current-friendly): per-environment tfvars and backend keys

- `terraform.tfvars` per environment (not committed with secrets)
- S3 state key pattern example:
  - `01-core-infra/dev/terraform.tfstate`
  - `01-core-infra/qa/terraform.tfstate`

Option B (later): workspace or account-per-environment model

## Naming Conventions

- Resource prefixes: `<portfolio>-<env>-<component>`
- Examples:
  - `portfolio-dev-alb`
  - `portfolio-qa-rds`

## DNS Strategy

Production:

- Public hosted zone and customer-facing FQDN

Non-production:

- Internal subdomain pattern (example `qa.example.com`, `uat.example.com`), or
- ALB DNS only when no Route53 hosted zone exists

## Promotion Strategy

- Dev auto-deploy on merge to `main`
- QA/UAT promote via approved PR or release tag
- Prod deploy behind explicit approval

## Secrets Strategy

- Store credentials in AWS Secrets Manager
- Never commit plaintext secrets
- Rotate credentials on schedule where practical

## Guardrails

- Branch protection on `main`
- CODEOWNERS required reviews
- Required status checks before merge
