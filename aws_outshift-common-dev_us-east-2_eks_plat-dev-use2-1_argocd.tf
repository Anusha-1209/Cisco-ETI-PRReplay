# This file was created by Outshift Platform Self-Service automation.

locals {
  enrollment_name    = "argocd-sre-enrollment"
  argocd_k8s_name    = "eks-dev-gitops-1"
  argocd_aws_account = "eticloud-preproduction"
}

data "vault_generic_secret" "aws_argocd_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/${local.argocd_aws_account}/terraform_admin"
}

provider "kubernetes" {
  alias                  = "argocd"
  host                   = data.aws_eks_cluster.argocd.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.argocd.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.argocd.token
}
provider "kubernetes" {
  alias                  = "eks"
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

data "aws_eks_cluster" "argocd" {
  name       = local.argocd_k8s_name
  provider   = aws.argocd
  depends_on = [module.eks_all_in_one]
}

data "aws_eks_cluster_auth" "argocd" {
  name     = local.argocd_k8s_name
  provider = aws.argocd
}

provider "aws" {
  alias       = "argocd"
  access_key  = data.vault_generic_secret.aws_argocd_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_argocd_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}

resource "kubernetes_service_account" "eks_service_account" {
  provider = kubernetes.eks
  metadata {
    name      = local.enrollment_name
    namespace = "kube-system"
  }
  secret {
    name = local.enrollment_name
  }
}

resource "kubernetes_secret" "eks_kubernetes_secret" {
  provider = kubernetes.eks
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = local.enrollment_name
    }
    namespace = "kube-system"
    name      = local.enrollment_name
  }
  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_cluster_role" "eks_cluster_role" {
  provider = kubernetes.eks
  metadata {
    name = local.enrollment_name
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

resource "kubernetes_cluster_role_binding_v1" "eks_cluster_role_binding" {
  provider = kubernetes.eks
  metadata {
    name = local.enrollment_name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = local.enrollment_name
  }
  subject {
    kind      = "ServiceAccount"
    name      = local.enrollment_name
    namespace = "kube-system"
  }
}

resource "kubernetes_secret" "argocd_kubernetes_secret" {
  provider = kubernetes.argocd
  metadata {
    name      = "cluster-${local.name}"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
  }

  data = {
    server = data.aws_eks_cluster.eks.endpoint,
    name   = local.name
    config = <<-EOT
    {
      "bearerToken": "${kubernetes_secret.eks_kubernetes_secret.data["token"]}",
      "tlsClientConfig": {
        "insecure": false,
        "caData": "${data.aws_eks_cluster.eks.certificate_authority[0].data}"
      }
    }
    EOT
  }

  type = "Opaque"
}
