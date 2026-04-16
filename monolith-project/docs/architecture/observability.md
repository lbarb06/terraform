# Observability

## Goal

Ensure platform and application health can be detected, visualized, and acted on quickly.

## Current Coverage

From `archive/2026-04-cleanup/04-observability (archived)`:

- CloudWatch dashboard for ALB, ASG, and RDS
- Alarms for ALB 5xx and latency
- Alarm for unhealthy ALB targets
- Alarm for low ASG in-service instances
- RDS CPU and storage alarms
- Optional SNS alert notifications

## Operational Usage

- Use dashboard during deployments and incidents
- Use alarm history to correlate service degradation windows
- Route alarm notifications to email/SNS subscriber

## Application-Level Observability (Next)

Recommended additions:

- Structured JSON logs
- Request correlation IDs
- App-level latency/error metrics
- SLOs for availability and latency

## Suggested SLO Starters

- Availability: 99.9% monthly
- API p95 latency target
- Error-rate threshold per endpoint

## Incident Readiness

Link this doc with runbooks in `kubernetes/runbooks` and drills in `kubernetes/incident-drills`.
