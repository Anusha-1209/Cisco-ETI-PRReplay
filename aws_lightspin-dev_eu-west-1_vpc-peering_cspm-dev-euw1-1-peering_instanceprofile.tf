provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/${local.eks_aws_account_name}/terraform_admin"
}

provider "aws" {
  alias       = "eks"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = local.region
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = local.name
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Restricted"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "Outshift SRE"
    }
  }
}

locals {
  name             = "cspm-dev-euw1-1"
  region           = "eu-west-1"
  eks_aws_account_name = "lightspin-dev"
}


# Instance profile for legacy karpenter
resource "aws_iam_instance_profile" "ip" {
  name = "KarpenterNodeInstanceProfile-${local.name}"
  role = "KarpenterNodeRole-${local.name}"
}