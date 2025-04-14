terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket  = "eticloud-tf-state-nonprod"                                                   # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key     = "terraform-state/aws/rosey-test/eu-west-1/eks/rosey-dev-euw1-1.tfstate"       # UPDATE ME.
    # This is the region where the backend S3 bucket is located.
    region  = "us-east-2"                                                                   # DO NOT CHANGE.

  }
}

locals {
  name = "rosey-dev-euw1-1"
}

data "aws_eks_cluster" "this" {
  name = local.name
}

data "vault_generic_secret" "cluster_certificate" {
    path = "secret/infra/eks/${local.name}/certificate"
}

module "eks_all_in_one" {
  source            = "../../../../../modules/eks_all_in_one"

  name              = local.name              # EKS cluster name
  region            = "eu-west-1"             # AWS provider region
  aws_account_name  = "rosey-test"            # AWS account name
  cidr              = "10.0.0.0/16"           # VPC CIDR
  cluster_version   = "1.28"                  # EKS cluster version

  # EKS Managed Private Node Group
  instance_types    = ["m6a.large"]           # EKS instance types
  min_size          = 3                       # EKS node group min size
  max_size          = 10                      # EKS node group max size
  desired_size      = 3                       # EKS node group desired size
}

module "eticloud_setup_external_secrets_operator" {
  source               = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=0.0.2"
  cluster_name         = local.name
  vault_namespace      = "eticloud"
  kubernetes_host      = data.aws_eks_cluster.this.endpoint
  kubernetes_ca        = data.vault_generic_secret.cluster_certificate.data["b64certificate"]
  policies             = ["external-secrets-dev"]
}