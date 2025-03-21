module "eks-dev-3" {
  source = "../../../../../modules/eks"
}

################################################################################
# Account
################################################################################


################################################################################
# Account
################################################################################

terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-nonprod"
    key     = "terraform-state/aws/eticloud-scratch-c/us-east-2/eks/eks-butterscotch-1.tfstate"
    region  = "us-east-2"
  }
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = var.region
  default_tags {
    tags = {
      ApplicationName    = var.application_name
      CiscoMailAlias     = var.cisco_mail_alias
      DataClassification = var.data_classification
      DataTaxonomy       = var.data_taxonomy
      Environment        = var.environment
      ResourceOwner      = var.resource_owner
    }
  }
}

provider "vault" {
  alias     = "eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/eticcprod/infra/eticloud-scratch-c/aws"
  provider = vault.eticcprod
}