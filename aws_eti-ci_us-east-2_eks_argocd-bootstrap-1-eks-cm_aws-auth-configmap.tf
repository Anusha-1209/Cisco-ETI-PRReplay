provider "vault" {
  alias     = "eticloud_eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/eticcprod/infra/ci/aws"
  provider = vault.eticloud_eticcprod
}

terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-nonprod"                                                               # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key     = "terraform-state/aws-eti-ci/eks/us-east-2/argocd-bootstrap-1-eks-cm.tfstate"              # Note the path here. It should match the patten terraform_state/<service>/<region>/<name>.tfstate
    region  = "us-east-2"                                                                               # Do not change
  }
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "3.4.0"
    }
  }
}

variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-east-2" #Set the region for the resources to be created.
}

# Infra AWS Provider
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.AWS_INFRA_REGION
  max_retries = 3
  default_tags {
    tags = {
      DataClassification = "Cisco Restricted"
      Environment        = "NonProd"
      ApplicationName    = "argocd-bootstrap-1"
      ResourceOwner      = "eti sre"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataTaxonomy       = "Cisco Operations Data"
    }
  }
}

data "vault_generic_secret" "cluster_certificate" {
    path = "secret/infra/eks/argocd-bootstrap-1/certificate"
}

data "vault_generic_secret" "aws_auth_configmap"{
    path = "secret/infra/eks/argocd-bootstrap-1/aws-auth"
}

data "aws_eks_cluster" "cluster" {
  name = "argocd-bootstrap-1"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "argocd-bootstrap-1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  token                  = data.aws_eks_cluster_auth.cluster.token
  alias                  = "eks"
}

resource "kubernetes_config_map_v1_data" "aws_auth_sre_data" {
  provider = kubernetes.eks
  force    = true

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data       = local.aws_auth_configmap_data
}

locals {
    aws_auth_configmap_b64_decode = base64decode(data.vault_generic_secret.aws_auth_configmap.data["sre_configmap_json_b64"])
    aws_auth_configmap_json_decode = jsondecode(local.aws_auth_configmap_b64_decode)
    aws_auth_configmap_data = {
        mapRoles = yamlencode(local.aws_auth_configmap_json_decode)
    }
}