terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws/motific-prod/servicerole/autoscaling-amazonaws-com.tfstate"
    region = "us-east-2"
  }
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

# Provider for us-east-2
provider "aws" {
  alias       = "east"
  region      = "us-east-2"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
}

# Provider for us-west-2
provider "aws" {
  alias       = "west"
  region      = "us-west-2"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
}

locals {
  aws_account_name = "motific-prod"
}

resource "aws_iam_service_linked_role" "AWSServiceRoleForAutoScalingEast" {
  provider = aws.east
  aws_service_name = "autoscaling.amazonaws.com"
}

resource "aws_iam_service_linked_role" "AWSServiceRoleForAutoScalingWest" {
  provider = aws.west
  aws_service_name = "autoscaling.amazonaws.com"
}