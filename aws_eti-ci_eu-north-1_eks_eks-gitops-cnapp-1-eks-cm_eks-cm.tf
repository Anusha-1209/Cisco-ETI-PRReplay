# This codebase should be modularized.
# This provider allows acces to the eticloud/eticcprod namespace in Keeper. Do not modify it without discussing with the SRE team.
provider "vault" {
  alias     = "eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

# Change `path = "secret/eticcprod/infra/<account_name>/aws" to specify the account in which the resources will be created. 
# Must match the account in which the VPC was created.
data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/eticcprod/infra/ci/aws"
  provider = vault.eticcprod
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"                                                           # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key    = "terraform-state/aws-eti-ci/vpc/eu-north-1/eks-gitops-cnapp-1-eks-cm.tfstate" # Note the path here. It should match the patten terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                                                        # Do not change
    # profile = "eticloud" # if you are doing developing Terraform, you can specify a local profile to use for accessing the statefile ONLY. A CLI login to Keeper is also required.
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
  default     = "eu-north-1" # The region in which the EKS cluster will be created. Must match the region in which the VPC was created.
}

# Infra AWS Provider
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.AWS_INFRA_REGION
  max_retries = 3
  default_tags {
    # These tags are required for security compliance. For more information on Data Classification and Data Taxonomy, please talk to the SRE team.
    tags = {
      ApplicationName    = "eks-gitops-cnapp-1-eks"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Restricted"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "Prod"
      ResourceOwner      = "Outshift SRE"
    }
  }
}

# The secrets below are in the `eticloud` namespace.
data "vault_generic_secret" "cluster_certificate" {
  path = "secret/infra/eks/eks-gitops-cnapp-1/certificate"
}

data "vault_generic_secret" "aws_auth_configmap" {
  path = "secret/infra/eks/eks-gitops-cnapp-1/aws-auth"
}

data "aws_eks_cluster" "cluster" {
  name = "eks-gitops-cnapp-1"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "eks-gitops-cnapp-1"
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

  data = local.aws_auth_configmap_data
}

locals {
  aws_auth_configmap_b64_decode  = base64decode(data.vault_generic_secret.aws_auth_configmap.data["sre_configmap_json_b64"])
  aws_auth_configmap_json_decode = jsondecode(local.aws_auth_configmap_b64_decode)
  aws_auth_configmap_data = {
    mapRoles = yamlencode(local.aws_auth_configmap_json_decode)
  }
}

# #---------- Enroll clusters to argocd
module "scs-dev-vcluster-1" {
  source               = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-argo-cluster-enrollment.git?ref=0.0.3"
  cluster_name         = "scs-dev-vcluster-1"
  mode                 = "server"
  providers = {
      kubernetes = kubernetes.eks
  }
}

module "scs-prod-1" {
  source               = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-argo-cluster-enrollment.git?ref=0.0.3"
  cluster_name         = "scs-prod-1"
  mode                 = "server"
  providers = {
      kubernetes = kubernetes.eks
  }
}


module "scs-prod-2" {
  source               = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-argo-cluster-enrollment.git?ref=0.0.3"
  cluster_name         = "scs-prod-2"
  mode                 = "server"
  providers = {
      kubernetes = kubernetes.eks
  }
}