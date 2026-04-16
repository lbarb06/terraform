# ADR 0002: Use Argo CD For Kubernetes Deployments

## Status

Accepted

## Context

The platform requires traceable, declarative Kubernetes deployments with reproducible rollouts and easy rollback behavior.

## Decision

Adopt GitOps with Argo CD:

- Store desired manifests in repository
- Update image tags through CI
- Let Argo CD reconcile cluster state from Git

## Consequences

Positive:

- Declarative source of truth
- Improved deployment auditability
- Easier rollback by reverting manifest history

Negative:

- Additional operational component to manage
- Requires branch/path governance for manifest changes
