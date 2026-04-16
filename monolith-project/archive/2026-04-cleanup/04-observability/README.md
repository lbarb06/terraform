# 04-observability (CloudWatch)

This module provisions CloudWatch dashboards and alarms for infrastructure created by `terraform/01-core-infra`.

## What It Creates

- Dashboard focused on ALB, ASG, RDS, and EC2 app logs
- ALB error/latency alarms
- Unhealthy target alarms
- Auto Scaling in-service capacity alarm
- RDS CPU and free storage alarms
- Optional SNS topic and email subscription

## Dependency

This module reads remote state outputs from `terraform/01-core-infra`.

Apply `terraform/01-core-infra` first, with remote state in S3 and at least one successful apply.

## Notes

- Dashboard includes a CloudWatch Logs Insights widget when `ec2_app_log_group_name` is available from core-infra outputs.
- Use `alarm_email` to receive alarm notifications by email (after SNS subscription confirmation).

## Usage

```bash
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```
