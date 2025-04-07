/* 
Created this ESO config file in its own directory to allow it to have its own tfstate 
as a workaround to Atlantis apply failure as it kept trying to modify resources related to the comn-dev-use2-1 cluster tfstate
*/

terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-nonprod"
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/eticloud/us-east-2/eks/eso-outshift-users-comn-dev-use2-1.tfstate"
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2" # DO NOT CHANGE.
  }
}

locals {
  name             = "comn-dev-use2-1"
  region           = "us-east-2"
  aws_account_name = "outshift-common-dev"
  account_id       = "471112537430"
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = local.region
}

data "aws_eks_cluster" "cluster" {
  name       = local.name
}

data "vault_generic_secret" "cluster_certificate" {
  provider   = vault.eticloud
  path       = "secret/infra/eks/${local.name}/certificate"
  
}

module "eso_eticloud_apps_outshift_users" {
  source          = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=1.0.0"
  cluster_name    = local.name
  vault_namespace = "eticloud/apps/outshift-users"
  kubernetes_host = data.aws_eks_cluster.cluster.endpoint
  kubernetes_ca   = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  policies        = ["external-secrets-${local.name}"]
}
