# ADR 0001: Use A Portfolio Monorepo

## Status

Accepted

## Context

The project includes Terraform modules, application code, CI/CD workflows, QA assets, and operational runbooks. Managing this across multiple repositories would increase coordination overhead for a single-maintainer portfolio.

## Decision

Use a single monorepo with clear top-level domains:

- `terraform/`
- `apps/`
- `qa/`
- `kubernetes/`
- `ci-cd/`
- `docs/`

## Consequences

Positive:

- Easier end-to-end visibility
- Simpler onboarding and demo flow
- Shared versioning and change traceability

Negative:

- Repository size grows over time
- Requires clear code ownership and path-based CI optimization
