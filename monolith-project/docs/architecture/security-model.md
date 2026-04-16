# Security Model

## Objective

Document baseline security controls for identity, secrets, access boundaries, and change control.

## Identity And Access

- CI uses GitHub OIDC role assumption (`AWS_ROLE_TO_ASSUME`)
- Avoid static AWS access keys in CI secrets
- Use least-privilege IAM policies where possible

## Secrets Management

- DB password is generated and stored in AWS Secrets Manager
- Application reads secret at runtime through approved mechanism
- No plaintext secrets in repository

## Terraform State Security

- Remote state stored in S3 backend
- Restrict bucket access to authorized principals
- Prefer bucket versioning and encryption controls
- Keep backend config local (`backend.hcl` ignored by git)

## Network Security Baseline

- RDS in private subnets
- Restrictive security groups between app and DB
- ALB as controlled ingress point

## Kubernetes Security Baseline

- Prefer IRSA for workload AWS permissions
- Restrict cluster-admin usage
- Consider image scanning and admission controls

## SDLC Controls

- Branch protection on `main`
- Required PR review
- Required status checks
- CODEOWNERS for path-based approval routing

## Logging And Monitoring

- CloudWatch alarms for key failure modes
- Dashboard visibility for ALB/ASG/RDS health
- Expand with centralized log search and retention policy

## Known Gaps (Portfolio Scope)

- Not a full zero-trust implementation
- No dedicated multi-account security boundary yet
- No full compliance control mapping yet
