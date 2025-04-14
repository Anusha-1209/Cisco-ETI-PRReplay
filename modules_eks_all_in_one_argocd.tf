resource "kubernetes_service_account_v1" "argocd_manager" {
  count       = var.enroll_cluster_in_argocd ? 1 : 0
  provider    = kubernetes.eks
  secret {
    name = "${local.argocd_manager_service_account_name}-token"
  }
  metadata {
    name      = local.argocd_manager_service_account_name
    namespace = local.argocd_manager_namespace
  }
  depends_on = [ kubernetes_secret.argocd_manager ]
}

resource "kubernetes_secret" "argocd_manager" {
  count         = var.enroll_cluster_in_argocd ? 1 : 0
  provider      = kubernetes.eks
  metadata {
    name          = "${local.argocd_manager_service_account_name}-token"
    namespace     = local.argocd_manager_namespace
    annotations   = {
      "kubernetes.io/service-account.name" = local.argocd_manager_service_account_name
    }
  }
  wait_for_service_account_token = false
  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_cluster_role" "argocd_manager" {
  count         = var.enroll_cluster_in_argocd ? 1 : 0

  provider      = kubernetes.eks
  metadata {
    name = "${local.argocd_manager_service_account_name}-role"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    non_resource_urls = ["*"]
    verbs             = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "argocd_manager" {
  count         = var.enroll_cluster_in_argocd ? 1 : 0

  provider      = kubernetes.eks
  metadata {
    name = "argocd-manager-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.argocd_manager[0].metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.argocd_manager[0].metadata.0.name
    namespace = kubernetes_service_account_v1.argocd_manager[0].metadata.0.namespace
  }
  depends_on = [ kubernetes_cluster_role.argocd_manager ]
}

## Add AWS EKS cluster to ArgoCD
resource "argocd_cluster" "eks" {
  count       = var.enroll_cluster_in_argocd ? 1 : 0
  server      = local.cluster_endpoint
  name        = local.name

  config {
    tls_client_config {
      ca_data = base64decode(local.cluster_auth_base64)
    }
  }
  depends_on = [ kubernetes_secret.argocd_manager ]
}