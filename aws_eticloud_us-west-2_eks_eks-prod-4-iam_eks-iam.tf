provider "vault" {
  alias     = "eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path     = "secret/eticcprod/infra/prod/aws"
}

terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-prod"                               # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key     = "terraform-state/eks/us-west-2/eks-prod-4-iam.tfstate" #note the path here. It should match the patten terraform_state/<service>/<region>/<name>.tfstate
    region  = "us-east-2" #do not change
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
  default     = "us-west-2" #Set the region for the resources to be created.
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
      Environment        = "Prod"
      ApplicationName    = "eks-prod-4-eks"
      ResourceOwner      = "eti sre"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataTaxonomy       = "Cisco Operations Data"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "selected" {
  name = "eks-prod-4" # <----this could be variablized for a module.
}

# assume the policy has been by a separate Terraform apply/Atlantis project. Add a `try` in a module.

data "aws_iam_policy" "aws_alb_controller_policy" {
  name = "AWSLoadBalancerControllerIAMPolicy"
}

data "aws_iam_policy_document" "aws_alb_controller_sa_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.selected.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-alb-controller-sa"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.selected.identity[0].oidc[0].issuer, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.selected.identity[0].oidc[0].issuer, "https://", "")}"]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_alb_controller_driver" {
  name               = "AmazonEKSLoadBalancerControllerRole-${data.aws_eks_cluster.selected.name}"
  assume_role_policy = data.aws_iam_policy_document.aws_alb_controller_sa_assume_role_policy.json

  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "eks_alb_controller_attachment" {
  role       = aws_iam_role.eks_alb_controller_driver.name
  policy_arn = data.aws_iam_policy.aws_alb_controller_policy.arn
}