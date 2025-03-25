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

  eks_irsa = {
    secrets_manager_ro = {
        eks-dragonfly-demo = {
            services_accounts = ["system:serviceaccount:external-secrets:aws-secretstore"],
            resources_names = ["*"]
        },
    }
    aws_alb_irsa = {
        eks-dragonfly-demo = {
            services_accounts = ["system:serviceaccount:kube-system:aws-load-balancer-controller"],
            eks_oidc          = "${replace(data.aws_eks_cluster.dragonfly-demo-euw1-1.identity[0].oidc[0].issuer, "https://", "")}"
        },
        eks-dragonfly-target = {
            services_accounts = ["system:serviceaccount:kube-system:aws-load-balancer-controller"],
            eks_oidc          = "${replace(data.aws_eks_cluster.dragonfly-target-euw1-1.identity[0].oidc[0].issuer, "https://", "")}"
        }
    }
  }
}

module "aws_iam" {
  # EKS cluster partially created as of Jan 29 2024
  source = "git::https://github.com/cisco-eti/sre-tf-module-aws-iam.git?ref=iam-management" # Based on v0.0.10


  region           = local.region             # AWS provider region
  aws_account_name = local.aws_account_name   # AWS account name
  eks_irsa         = local.eks_irsa           # EKS IRSA

}
