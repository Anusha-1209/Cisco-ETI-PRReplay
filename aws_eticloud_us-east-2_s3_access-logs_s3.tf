data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/eticcprod/infra/prod/aws"
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/s3/us-east-2/access-logs.tfstate"
    region = "us-east-2"
  }
}

variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-east-2"
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.AWS_INFRA_REGION
  max_retries = 3
}

module "s3" {
  source      = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-s3.git?ref=1.0.0"
  bucket_name = "cisco-eti-access-logs"

  CSBDataClassification = "Cisco Restricted"
  CSBEnvironment        = "Prod"
  CSBApplicationName    = "ETICloud"
  CSBResourceOwner      = "ETI SRE"
  CSBCiscoMailAlias     = "eti-sre@cisco.com"
  CSBDataTaxonomy       = "Cisco Operations Data"
}
