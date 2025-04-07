provider "vault" {
  alias     = "eticloud_eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod" 
    key    = "terraform-state/aurora-postgres/us-east-2/rds-vowel-dev-1.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "rds-vowel-dev-1"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "NonProd"
      ResourceOwner      = "ETI SRE"
    }
  }
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/eticcprod/infra/vowel-genai-dev/aws"
  provider = vault.eticloud_eticcprod
}


module "rds" {
  source           = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-aurora-postgres?ref=1.0.4"
  vpc_name         = "rds-vowel-dev-1-vpc"
  database_name    = "vowel_temporal"
  db_instance_type = "db.r5.xlarge"
  cluster_name     = "vowel-dev-1"
  db_allowed_cidrs = ["10.1.0.0/16"]
}
