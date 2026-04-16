# System Overview

## Purpose

This repository is a platform portfolio monorepo that demonstrates how infrastructure, application delivery, testing, and operations fit together in a production-style workflow.

## Current State

Implemented now:

- `terraform/01-core-infra`: VPC, ALB, ASG/EC2 runtime, RDS, Secrets Manager, optional Route53
- `terraform/02-k8s-platform`: EKS, ECR, GitHub OIDC role
- `terraform/03-gitops-argocd`: Argo CD install and app bootstrap path
- `archive/2026-04-cleanup/04-observability (archived)`: CloudWatch dashboard and alarms
- `.github/workflows/webapp-cicd.yml`: test, build, ECR push, GitOps manifest update

Target direction:

- Keep core infra as base while shifting app runtime to GitOps on EKS.

## Scope

The portfolio covers:

- AWS core infrastructure provisioning with Terraform
- Kubernetes platform provisioning and GitOps deployment
- Application build/test/deploy pipeline
- Observability and alerting
- QA and operational support artifacts

## High-Level Components

- `terraform/01-core-infra`
  - VPC, subnets, ALB, ASG, RDS, Secrets Manager, optional Route53
- `terraform/02-k8s-platform`
  - EKS cluster, node groups, ECR, GitHub OIDC role
- `terraform/03-gitops-argocd`
  - Argo CD installation and bootstrap application
- `archive/2026-04-cleanup/04-observability (archived)`
  - CloudWatch dashboards and alarms
- `terraform/04-infra-cicd`
  - CodePipeline and CodeBuild for infra CI/CD
- `apps/webapp`
  - Node.js web app with unit and UI tests

## Runtime Data Flow

1. End users call the application endpoint (ALB or DNS record).
2. Requests route to app runtime.
3. App reads DB credentials and connects to RDS MySQL.
4. Metrics and alarms flow into CloudWatch.

## Delivery Data Flow

1. Developer pushes commit to `main` or opens PR.
2. GitHub Actions runs unit and Playwright UI tests.
3. Workflow assumes AWS role via OIDC.
4. Docker image is built and pushed to ECR.
5. GitOps manifest is updated with the new image tag.
6. Argo CD syncs desired state to EKS.

## Diagrams

- [System Context Diagram](./diagrams/system-context.md)
- [Delivery Flow Diagram](./diagrams/delivery-flow.md)
- [Environment Topology Diagram](./diagrams/environment-topology.md)

## Non-Goals

- Full enterprise landing zone with multi-account guardrails
- Full compliance mapping
- Complete SRE organizational process model
