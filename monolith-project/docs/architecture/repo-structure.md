# Repository Structure

## Why Monorepo

This portfolio uses a monorepo to keep infrastructure, application code, CI/CD logic, and operations artifacts in one place. For a single maintainer or small team, this improves discoverability and reduces cross-repo drift.

## Top-Level Layout

- `terraform/`
  - `01-core-infra/`
  - `02-k8s-platform/`
  - `03-gitops-argocd/`
  - `04-observability/`
  - `05-infra-cicd/`
- `apps/`
  - `webapp/`
- `qa/`
  - `ui-test-suites/`, `test-data/`
- `kubernetes/`
  - `troubleshooting/`, `runbooks/`, `incident-drills/`
- `ci-cd/`
  - `github-actions/`, `jenkins/`
- `docs/`
  - `architecture/`, `onboarding/`

## Ownership Model

Recommended CODEOWNERS pattern:

- `/terraform/01-core-infra/`
- `/terraform/02-k8s-platform/`
- `/terraform/03-gitops-argocd/`
- `/archive/2026-04-cleanup/04-observability (archived)/`
- `/terraform/04-infra-cicd/`
- `/apps/webapp/`
- `/qa/`, `/kubernetes/`, `/ci-cd/`, `/docs/`

## Branching Model

- Default branch: `main`
- Feature branches: `feature/<area>-<short-desc>`
- Fix branches: `fix/<area>-<short-desc>`
- Chore branches: `chore/<area>-<short-desc>`

## PR Conventions

Suggested title format:

- `[terraform/01-core-infra] add db subnet hardening`
- `[apps/webapp] add health endpoint coverage`

Suggested labels:

- `area:terraform`, `area:webapp`, `area:qa`, `area:k8s`, `area:ci-cd`, `docs`, `bug`, `enhancement`, `breaking`

## Tradeoffs

Benefits:

- End-to-end visibility in one repository
- Easier onboarding
- Simplified demo and portfolio storytelling

Costs:

- Larger repo over time
- Requires stricter path ownership and review hygiene
- CI workflows may need selective path triggers to stay efficient
