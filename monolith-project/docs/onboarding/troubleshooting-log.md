# Troubleshooting Log (Build, Deploy, Verify, Destroy)

Date range: 2026-04-03 to 2026-04-04  
Region: `us-east-1`  
Profile: `admin`

## 1) Route53 hosted zone lookup failed
Error:
- `no matching Route 53 Hosted Zone found`

Cause:
- `var.route53_zone_name` pointed to a zone not present in account.

Resolution:
- Use ALB DNS directly for non-prod or create Route53 hosted zone first.

## 2) Terraform state/backend confusion
Symptoms:
- No local `.tfstate` found after `init/plan`.

Cause:
- Remote backend in S3 used.

Resolution:
- Confirm backend config and remote state location; no migration needed if never applied locally.

## 3) Playwright test boot issues
### A) `test() called here` error
Cause:
- Playwright test/import/config mismatch.

Resolution:
- Ensure tests only in test files and run with `playwright test`.

### B) `ERR_CONNECTION_REFUSED` to `127.0.0.1:3000`
Cause:
- App not running before UI tests.

Resolution:
- Start app or use Playwright `webServer` config.

### C) CI error `.../health is already used`
Cause:
- Double startup (`npm start &` + Playwright `webServer`).

Resolution:
- Remove manual `npm start &` step; keep only `npm run test:ui`.

## 4) Unit test dependency failure
Error:
- `Cannot find package 'mysql2/promise'`

Cause:
- Missing dependency in webapp package.

Resolution:
- Install and lock dependency in app (`mysql2`), rerun tests.

## 5) Module 01 apply failed (RDS free-tier)
Error:
- `FreeTierRestrictionError`

Cause:
- RDS settings incompatible with free-tier limits.

Resolution:
- Reduced backup retention setting to compliant value.

## 6) Module 02 EKS node-group launch failures
Errors:
- `AsgInstanceLaunchFailures`
- `NodeCreationFailure`

Causes:
- Instance type/capacity mismatch
- Subnet/routing choice not appropriate for worker bootstrap

Resolution:
- Adjusted node size/count.
- Corrected subnet use for EKS node group.

## 7) Module 03 Argo install timeout
Error:
- Helm release timeout / failed pre-install.

Cause:
- Insufficient cluster pod capacity; tainted release remained.

Resolution:
- Increased node capacity.
- Re-applied module and replaced tainted Helm release.

## 8) Argo app manifest missing/path issues
Error:
- `path ... argocd-application.yaml does not exist`

Cause:
- Manifest missing in repo path.

Resolution:
- Recreated `apps/webapp/k8s/argocd-application.yaml`.
- Committed via branch+PR workflow.

## 9) Argo app `Unknown` / resources pruned
Symptom:
- App showed Synced/Healthy but webapp service disappeared.

Cause:
- Source manifests in Git no longer contained expected resources; Argo pruned them.

Resolution:
- Restored `deployment.yaml`, `service.yaml`, `kustomization.yaml`.
- Refreshed/resynced Argo app.

## 10) YAML parse failure in deployment
Error:
- `MalformedYAMLError ... line 32`

Cause:
- Invalid YAML formatting.

Resolution:
- Replaced with valid deployment manifest structure.

## 11) Argo sync failed with invalid Deployment spec
Error:
- `containers[1].name: Invalid value: "DB_HOST"... image required`

Cause:
- DB env entries were added under `containers` list, not under `env` for main container.

Resolution:
- Moved `DB_HOST/DB_USER/DB_PASSWORD/DB_NAME` under `containers[0].env`.

## 12) API endpoint mismatch
Error:
- `Cannot POST /api/items`

Cause:
- Correct implemented route is `/api/messages`.

Resolution:
- Verified server routes and updated test calls.

## 13) DB not configured / connectivity errors
Errors:
- `Database is not configured`
- `connect ETIMEDOUT`

Causes:
- Missing DB env vars in pod.
- Placeholder password used.
- RDS ingress path not open from app runtime network.

Resolution:
- Created/updated `webapp-db` secret.
- Set deployment env vars (and later persisted in manifests).
- Added RDS ingress rule for MySQL path.
- Pulled real credentials from Secrets Manager.

## 14) Zsh command pitfalls
Symptoms:
- `zsh: command not found: #`
- parse errors in pasted multi-line blocks.

Cause:
- Pasting comment lines and incompatible shell fragments.

Resolution:
- Run raw commands without comment lines.
- Use simpler one-line commands when needed.

## 15) Destroy blocked by ECR repo not empty
Error:
- `RepositoryNotEmptyException`

Resolution:
- Deleted ECR images, reran destroy.

## 16) Destroy blocked by VPC dependencies
Errors:
- Subnet dependency violation
- IGW detach blocked by mapped public addresses
- VPC dependency violation

Cause:
- Leftover ELB ENIs (classic ELB), residual SG dependency.

Resolution:
- Identified ENIs in subnets.
- Deleted classic ELB.
- Removed remaining non-default SG.
- Reran Terraform destroy successfully.

## 17) S3 backend bucket delete failed
Error:
- `BucketNotEmpty`

Cause:
- Versioned bucket requires deleting versions + delete markers first.

Resolution:
- Deleted object versions and delete markers, then deleted bucket.
- Lock table already absent (`ResourceNotFoundException`).

## Final confirmed outcomes
- Infra resources destroyed (EKS, RDS, ELBs, ECR repos empty).
- Remote tfstate bucket removed.
- Application E2E was successfully verified before teardown:
  - `/health` 200
  - `/api/messages` GET/POST working with DB persistence.
