terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-nonprod"
    key     = "terraform-state/aws-dragonfly-demo-1/iam/roles.tfstate"
    region  = "us-east-2"
  }
}

data "aws_eks_cluster" "dragonfly-demo-euw1-1" {
  name = "dragonfly-demo-euw1-1"
}
data "aws_eks_cluster" "dragonfly-target-euw1-1" {
  name = "dragonfly-tgt-euw1-1"
}

locals {
  aws_region       = "eu-west-1"
  aws_account_name = "dragonfly-demo"
  aws_account_id   = "545452251603"
  app_name         = "dragonfly-demo"

  eks_irsa = {
    secrets_manager_ro = {
        eks-dragonfly-demo = {
            eks_oidc          = "${replace(data.aws_eks_cluster.dragonfly-demo-euw1-1.identity[0].oidc[0].issuer, "https://", "")}"
            eks_cluster_name  = data.aws_eks_cluster.dragonfly-demo-euw1-1.name
            services_accounts = ["system:serviceaccount:external-secrets:aws-secretstore"],
            resources_names   = ["*"]
        },
    }
    aws_alb_irsa = {
        eks-dragonfly-demo = {
            eks_oidc          = "${replace(data.aws_eks_cluster.dragonfly-demo-euw1-1.identity[0].oidc[0].issuer, "https://", "")}"
            eks_cluster_name  = data.aws_eks_cluster.dragonfly-demo-euw1-1.name
            services_accounts = ["system:serviceaccount:kube-system:aws-load-balancer-controller"],
            resources_names   = []
        },
        eks-dragonfly-target = {
            eks_oidc          = "${replace(data.aws_eks_cluster.dragonfly-target-euw1-1.identity[0].oidc[0].issuer, "https://", "")}"
            eks_cluster_name  = data.aws_eks_cluster.dragonfly-target-euw1-1.name
            services_accounts = ["system:serviceaccount:kube-system:aws-load-balancer-controller"],
            resources_names   = []
        }
    }
  }
}

################################################################################
# Provider configuration
################################################################################
provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider    = vault.eticloud
  path        = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "eu-west-1"
}

module "aws_iam" {
  # EKS cluster partially created as of Jan 29 2024
  source = "git::https://github.com/cisco-eti/sre-tf-module-aws-iam.git?ref=iam-management"


  aws_region       = local.aws_region         # AWS provider region
  aws_account_name = local.aws_account_name   # AWS account name
  aws_account_id   = local.aws_account_id
  app_name         = local.app_name           # AWS tag app_name
  eks_irsa         = local.eks_irsa           # EKS IRSA

}
