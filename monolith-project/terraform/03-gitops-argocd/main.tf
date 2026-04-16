provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Purpose     = "gitops"
    }
  }
}

data "terraform_remote_state" "project_4" {
  backend = "s3"

  config = {
    bucket  = var.project_4_state_bucket
    key     = var.project_4_state_key
    region  = var.project_4_state_region
    profile = var.aws_profile
  }
}

data "aws_eks_cluster" "main" {
  name = data.terraform_remote_state.project_4.outputs.cluster_name
}

data "aws_eks_cluster_auth" "main" {
  name = data.terraform_remote_state.project_4.outputs.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}

locals {
  name_prefix      = "${var.project_name}-${var.environment}"
  bootstrap_gitops = var.bootstrap_application && var.gitops_repo_url != null
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
    labels = {
      app = "argocd"
    }
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  create_namespace = false

  values = [
    yamlencode({
      global = {
        domain = var.create_ingress ? var.argocd_hostname : null
      }
      server = {
        service = {
          type = var.create_ingress ? "ClusterIP" : "LoadBalancer"
        }
        ingress = {
          enabled = var.create_ingress
          hosts   = var.create_ingress ? [var.argocd_hostname] : []
        }
      }
    })
  ]
}

resource "kubernetes_namespace" "workload" {
  count = local.bootstrap_gitops ? 1 : 0

  metadata {
    name = var.gitops_destination_namespace
  }
}

resource "kubernetes_manifest" "project_1_application" {
  count = local.bootstrap_gitops ? 1 : 0

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "project1"
      namespace = var.argocd_namespace
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = var.gitops_repo_branch
        path           = var.gitops_app_path
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.gitops_destination_namespace
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }

  depends_on = [helm_release.argocd]
}
