output "argocd_namespace" {
  description = "Namespace where Argo CD is installed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_server_service_hint" {
  description = "Hint for where to find Argo CD server access"
  value       = var.create_ingress ? "Argo CD exposed via ingress hostname" : "Argo CD exposed via LoadBalancer service"
}

output "bootstrap_application_enabled" {
  description = "Whether bootstrap Argo CD Application was created"
  value       = local.bootstrap_gitops
}
