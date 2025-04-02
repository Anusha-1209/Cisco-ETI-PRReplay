provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

provider "vault" {
  alias     = "teamsecrets"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/teamsecrets"
}

provider "aws" {
  alias       = "this"
  access_key  = data.vault_generic_secret.aws_infra_credentials_accepter.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credentials_accepter.data["AWS_SECRET_ACCESS_KEY"]
  region      = local.accepter_region
  max_retries = 3
  default_tags {
    tags = {
      Name               = "VPC Peering between ${local.accepter_vpc_name} and ${local.requester_vpc_name}"
      ApplicationName    = "${local.accepter_vpc_name}-vpc-peering"
      CiscoMailAlias     = "eti-sre@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "Outshift SRE"
    }
  }
}

provider "aws" {
  alias       = "peer"
  access_key  = data.vault_generic_secret.aws_infra_credentials_requester.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credentials_requester.data["AWS_SECRET_ACCESS_KEY"]
  region      = local.requester_region
  max_retries = 3
  default_tags {
    tags = {
      Name               = "VPC Peering between ${local.accepter_vpc_name} and ${local.requester_vpc_name}"
      ApplicationName    = "${local.accepter_vpc_name}-vpc-peering"
      CiscoMailAlias     = "eti-sre@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "Outshift SRE"
    }
  }
}