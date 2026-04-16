# ADR 0003: Use GitHub OIDC Instead Of Static AWS Keys

## Status

Accepted

## Context

Static long-lived AWS keys in CI increase credential leakage risk and key rotation burden.

## Decision

Use GitHub Actions OIDC role assumption for AWS authentication.

## Consequences

Positive:

- Eliminates static CI keys
- Short-lived credentials per workflow run
- Better least-privilege control via IAM role policy

Negative:

- Initial IAM/OIDC setup complexity
- Requires careful trust policy scoping to repository/branch
