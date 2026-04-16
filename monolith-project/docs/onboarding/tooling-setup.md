# Tooling Setup

This guide covers local tools required for this repository on macOS.

## Required Tools

- AWS CLI v2
- Terraform (>= 1.5)
- Docker Desktop
- Node.js 20 + npm
- kubectl
- Helm 3

Optional but useful:

- GitHub CLI (`gh`)
- Argo CD CLI (`argocd`)

## 1) Install Homebrew (if needed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 2) Install Core Toolchain

```bash
brew install awscli terraform kubectl helm node gh
brew install --cask docker
```

Optional Argo CD CLI:

```bash
brew install argocd
```

## 3) Verify Installations

```bash
aws --version
terraform version
docker --version
kubectl version --client
helm version
node -v
npm -v
gh --version
argocd version --client
```

Note: `argocd` is optional. If not installed, skip that command.

## 4) Start Docker Desktop

Open Docker Desktop and wait until it reports running.

Quick check:

```bash
docker info
```

## 5) Configure AWS CLI Profile

```bash
aws configure --profile portfolio
```

Then verify account identity:

```bash
aws sts get-caller-identity --profile portfolio
```

## 6) Configure GitHub CLI (optional but recommended)

```bash
gh auth login
```

## 7) Repo-Specific Checks

From repository root:

```bash
cd ~/Desktop/monolith-project
```

Webapp checks:

```bash
cd apps/webapp
npm install
npm run test:unit
npm run test:ui
```

Terraform checks (example module):

```bash
cd ../../terraform/01-core-infra
terraform fmt -recursive
terraform init -backend-config=backend.hcl
terraform plan
```

## 8) Minimum Environment Variables Pattern

You can use AWS profile directly in Terraform variables (`aws_profile`) or export env vars.

Examples:

```bash
export AWS_PROFILE=portfolio
export AWS_REGION=us-east-1
```

## 9) Troubleshooting

`ERR_CONNECTION_REFUSED` in Playwright:

- Confirm app started before test (`npm start`)
- Confirm port `3000` is free
- Confirm Docker is running if your flow depends on containers

`no matching Route 53 Hosted Zone found`:

- Hosted zone does not exist in selected AWS account
- Wrong `route53_zone_name`
- Wrong AWS profile/account context

ECR push auth errors:

- Confirm OIDC role or local IAM permissions include ECR push actions
- Confirm repository URL and region match
