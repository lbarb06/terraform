# Networking And DNS

## Core Network Design

- VPC spans two availability zones
- Public and private subnet tiers
- ALB handles inbound web traffic
- RDS MySQL resides in private subnets

## Ingress Patterns

### Production

- Use Route53 hosted zone
- Create FQDN records (for example `app.example.com`) to ALB
- Add TLS via ACM for HTTPS

### Non-Production

- Use delegated subdomains (`qa.example.com`, `uat.example.com`), or
- Use ALB DNS endpoint directly when hosted zone is not available

## Why "No matching Route53 Hosted Zone" Happens

Terraform data source lookup fails when the configured hosted zone does not exist in the account/region context being used.

Common causes:

- Zone not created yet
- Wrong `route53_zone_name` value
- Wrong AWS profile/account selected

## Practical DNS Strategy For This Portfolio

- Start with `create_dns_record = false` in early environments
- Use ALB DNS output for smoke tests
- Enable Route53 integration when domain ownership and hosted zone are ready

## Future Improvements

- Add private hosted zones for internal services
- Add Route53 health checks and failover routing
- Enforce HTTPS listeners and redirect HTTP to HTTPS
