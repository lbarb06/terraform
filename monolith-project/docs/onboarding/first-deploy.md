# First Deploy (End-to-End)

This is the baseline deploy path validated in E2E.

## Prereqs
- AWS CLI configured (`admin` profile)
- Terraform installed
- kubectl installed
- Docker installed and running
- Repo cloned

```bash
export AWS_PROFILE=admin
export AWS_REGION=us-east-1
cd ~/Desktop/platform-portfolio
1) Deploy Infra (Terraform order)
bash

cd terraform/01-core-infra
terraform init -backend-config=backend.hcl
terraform apply -var-file=terraform.tfvars -auto-approve

cd ../02-k8s-platform
terraform init -backend-config=backend.hcl
terraform apply -var-file=terraform.tfvars -auto-approve

cd ../03-gitops-argocd
terraform init -backend-config=backend.hcl
terraform apply -var-file=terraform.tfvars -auto-approve

cd ../../
2) Configure kube context
bash

aws eks update-kubeconfig \
  --region us-east-1 \
  --name project1-k8s-main-cluster \
  --profile admin
3) Build and push webapp image
bash

export AWS_ACCOUNT_ID=015932245130
export ECR_REPO=project1-webapp
IMAGE_TAG=$(git rev-parse --short HEAD)
IMAGE_URI=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}

aws ecr get-login-password --region "$AWS_REGION" --profile "$AWS_PROFILE" \
| docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

docker build -t ${ECR_REPO}:${IMAGE_TAG} ./apps/webapp
docker tag ${ECR_REPO}:${IMAGE_TAG} ${IMAGE_URI}
docker push ${IMAGE_URI}
4) Deploy app manifests via Argo
Ensure image tag in apps/webapp/k8s/deployment.yaml is updated to ${IMAGE_TAG}.
Ensure apps/webapp/k8s/argocd-application.yaml exists.
bash

kubectl apply -f apps/webapp/k8s/argocd-application.yaml
kubectl annotate application webapp -n argocd argocd.argoproj.io/refresh=hard --overwrite
kubectl get app webapp -n argocd
5) Configure DB secret (required for API)
bash

kubectl create namespace webapp --dry-run=client -o yaml | kubectl apply -f -

kubectl -n webapp create secret generic webapp-db \
  --from-literal=DB_HOST='<rds-endpoint>' \
  --from-literal=DB_USER='<db-user>' \
  --from-literal=DB_PASSWORD='<db-password>' \
  --from-literal=DB_NAME='<db-name>' \
  --dry-run=client -o yaml | kubectl apply -f -
6) Verify deployment
bash

kubectl get app webapp -n argocd
kubectl get pods -n webapp
kubectl get svc -n webapp
LB=$(kubectl get svc webapp -n webapp -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -i "http://$LB/health"
curl -i "http://$LB/api/messages"
curl -i -X POST "http://$LB/api/messages" -H "Content-Type: application/json" -d '{"content":"first deploy check"}'
curl -i "http://$LB/api/messages"
Expected:

Argo app Synced/Healthy
/health returns 200
/api/messages GET/POST works and persists
