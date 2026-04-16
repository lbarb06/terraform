# Developer Workflow

## Branching
- Never commit directly to `main`.
- Create feature/fix branch from latest `main`.

```bash
git checkout main
git pull origin main
git checkout -b feat/<short-name>
Commit and Push
bash

git add -A
git commit -m "feat: <summary>"
git push -u origin feat/<short-name>
Pull Request
Base: main
Compare: your feature branch
Include:
what changed
why
test evidence (commands + outputs/screenshots)
Labels (recommended)
area/terraform
area/webapp
area/gitops
type/feature
type/fix
type/docs
risk/low|medium|high
CODEOWNERS flow
CODEOWNERS defines required reviewers by path.
If branch protection requires CODEOWNERS review, PR cannot merge without approval from listed owners.
Keep CODEOWNERS in repo root: .github/CODEOWNERS.
Merge policy
Require checks green.
Require review approval.
Squash merge preferred for cleaner history.
Post-merge
bash

git checkout main
git pull origin main
git branch -d feat/<short-name>
