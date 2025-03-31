data "aws_eks_cluster" "argocd" {
  provider   = aws.argocd
  name       = local.argocd_k8s_name
}

data "aws_eks_cluster_auth" "argocd" {
  provider   = aws.argocd
  name       = local.argocd_k8s_name
}

data "vault_generic_secret" "argocd_cluster_certificate" {
  path       = "secret/infra/eks/${local.argocd_k8s_name}/certificate"
}

resource "kubernetes_service_account_v1" "argocd_manager" {
  provider = kubernetes.target
  secret {
    name = "${local.argocd_manager_service_account_name}-token"
  }
  metadata {
    name      = local.argocd_manager_service_account_name
    namespace = local.argocd_manager_namespace
  }
}

resource "kubernetes_secret" "argocd_manager" {
  provider = kubernetes.target
  metadata {
    name      = "${local.argocd_manager_service_account_name}-token"
    namespace = local.argocd_manager_namespace
    annotations = {
      "kubernetes.io/service-account.name" = local.argocd_manager_service_account_name
    }
  }
  wait_for_service_account_token = true
  type                           = "kubernetes.io/service-account-token"
  depends_on = [kubernetes_service_account_v1.argocd_manager]
}

resource "kubernetes_cluster_role" "argocd_manager" {
  provider = kubernetes.target
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
  provider = kubernetes.target
  metadata {
    name = "argocd-manager-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.argocd_manager.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.argocd_manager.metadata.0.name
    namespace = kubernetes_service_account_v1.argocd_manager.metadata.0.namespace
  }
  depends_on = [kubernetes_cluster_role.argocd_manager]
}

## Add AWS EKS cluster to ArgoCD
resource "argocd_cluster" "eks" {
  server = data.aws_eks_cluster.argocd.endpoint
  name   = local.name
  config {
    tls_client_config {
      ca_data = base64decode(data.vault_generic_secret.argocd_cluster_certificate.data["b64certificate"])
    }
  }
  depends_on = [kubernetes_secret.argocd_manager]
}