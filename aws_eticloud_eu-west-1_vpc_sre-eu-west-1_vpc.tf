provider "vault" {
    alias = "eticcprod"
    address = "https://keeper.cisco.com"
    namespace = "eticloud/eticcprod"
}

# Atlantis has credentials to the eticloud AWS account. It uses those credentials to store and retrieve state information.
# `Path=` specifies the path to credentials in Keeper. The assumed namespace is eticloud/eticcprod.
# This data call is required for all accounts. The two current options are "scratch" (as below) and "prod".
data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path="secret/eticcprod/infra/prod/aws"
}

terraform {
  backend "s3" {
    bucket        = "eticloud-tf-state-nonprod"
    key           = "terraform-state/vpc/eu-west-1/sre-dev-eu-west-1-vpc.tfstate"
    region        = "us-east-2"
  }
}


variable "AWS_INFRA_REGION" {
  description     = "AWS Region"
  default         = "eu-west-1"
}


# By setting the AWS provider credentials via the data source above, we control in which account and region the resources get created.
provider "aws" {
  access_key      = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key      = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region          = var.AWS_INFRA_REGION
  max_retries     = 3
}


module "vpc" {
  source          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-vpc?ref=1.2.4"
  name            = "sre-eu-west-1"
  cidr            = "10.0.0.0/16"
  region          = "eu-west-1"
  hosted_zone_id  = "Z0137785FSHHHEYXY6C5"
  cluster_name    = "eks-dev-2"

  public_subnets  = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
  ]
  private_subnets =  [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
  CSBEnvironment = "Sandbox"
  CSBApplicationName = "eti-sre"
  CSBResourceOwner = "ETI SRE"
  CSBCiscoMailAlias = "eti-sre@cisco.com"
  CSBDataTaxonomy = "Operations Data"
  CSBDataClassification = "Cisco Confidential"
}
