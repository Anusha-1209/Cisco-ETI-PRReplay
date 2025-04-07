provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod" 
    key    = "terraform-state/aurora-postgres/eu-central-1/rds-apisec-prod-eu-1.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "eu-central-1"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "rds-apisec-prod-eu-1"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/apisec-prod/terraform_admin"
  provider = vault.eticloud
}


module "rds" {
  source            = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-aurora-postgres?ref=1.1.0"
  vpc_name          = "rds-apisec-prod-eu-1-vpc"
  database_name     = "apisec_k8s_service"
  db_instance_type  = "db.r5.xlarge"
  cluster_name      = "rds-apisec-prod-eu-1"
  secret_path       = "secret/eticcprod/infra/aurora-pg/eu-central-1/apisec-prod/rds-apisec-prod"
  db_allowed_cidrs  = ["10.1.0.0/16"]
  db_engine_version = "15"
}
