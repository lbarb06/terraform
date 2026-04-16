# Deployment Flow

## Objective

Define a repeatable path from code commit to deployed application with automated validation and controlled rollout.

## Flow Summary

1. Developer pushes code to branch and opens PR.
2. CI runs quality gates.
3. Merge to `main` triggers build and publish.
4. GitOps manifests are updated with new image tag.
5. Argo CD syncs Kubernetes desired state.
6. Post-deploy checks validate runtime.

## CI Stages

### Stage 1: Validation

- Install dependencies
- Lint (optional)
- Unit tests
- UI tests (local or containerized)

### Stage 2: Image Build

- Build Docker image for webapp
- Tag with commit SHA and/or release tag
- Push image to ECR

### Stage 3: GitOps Update

- Update deployment manifest image reference
- Commit or PR manifest change
- Ensure Argo CD target path and branch match

### Stage 4: Deployment

- Argo CD reconciles cluster state
- Rollout strategy applies (rolling update)
- Health checks gate completion

### Stage 5: Verification

- Smoke checks against `/health` and `/version`
- Optional Playwright test suite against deployed base URL
- Compare deployed version to commit SHA

## Required Inputs

- `AWS_REGION`
- `AWS_ROLE_TO_ASSUME` (OIDC)
- `ECR_REPOSITORY_URL`
- `WEBAPP_BASE_URL` (if deployed UI tests enabled)

## Failure Handling

- Fail fast on unit/UI test failures
- Prevent image push on failed tests
- Alert on deploy verification failures
- Roll back by re-pointing manifest to previous known-good image tag

## Manual Approval (Optional)

For higher environments, add manual approval before production rollout.

## Environment Promotion (Future)

Recommended evolution:

1. Build once on merge to `main`
2. Promote immutable image across `dev -> qa -> uat -> prod`
3. Use GitOps branch or folder promotion strategy
