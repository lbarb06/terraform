# Deploy Webapp (EKS + Argo)

## 1) Create/Update DB secret
kubectl -n webapp create secret generic webapp-db \
  --from-literal=DB_HOST='<rds-endpoint>' \
  --from-literal=DB_USER='<db-user>' \
  --from-literal=DB_PASSWORD='<db-password>' \
  --from-literal=DB_NAME='<db-name>' \
  --dry-run=client -o yaml | kubectl apply -f -

## 2) Apply Argo application
kubectl apply -f apps/webapp/k8s/argocd-application.yaml
kubectl annotate application webapp -n argocd argocd.argoproj.io/refresh=hard --overwrite

## 3) Verify app
LB=$(kubectl get svc webapp -n webapp -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -i "http://${LB}/health"
curl -i "http://${LB}/api/messages"
curl -i -X POST "http://${LB}/api/messages" -H "Content-Type: application/json" -d '{"content":"deploy-check"}'
curl -i "http://${LB}/api/messages"
