terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-nonprod"
    key            = "terraform-state/s3/us-east-1/eti-sre-imagebuilder-data.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}

variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-east-2"
}

provider "vault" {
    alias = "eticcprod"
    address = "https://keeper.cisco.com"
    namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path = "secret/eticcprod/infra/prod/aws"
}

provider "aws" {
  region      = var.AWS_INFRA_REGION
  max_retries = 3
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]

  default_tags {
    tags = {
      CiscoMailAlias = "eti-sre-admins@cisco.com"
      ResourceOwner  = "ETI SRE"
    }
  }
}


resource "aws_s3_bucket" "eti-sre-imagebuilder" {
  bucket = "cisco-eti-capi-images-ci"
  #Tags for CSB. More info here:
  #https://cisco.sharepoint.com/Sites/CSB/SitePages/Security%20Tagging%20and%20Audit%20in%20AWS.aspx
  tags = {
    DataClassification = "Cisco Confidential"
    Environment        = "NonProd"
    ApplicationName    = "eti-sre-imagebuilder"
    ResourceOwner      = "ETI SRE"
    CiscoMailAlias     = "sre_at_cisco_dot_com"
    DataTaxonomy       = "Cisco Operations Data"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.eti-sre-imagebuilder.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.eti-sre-imagebuilder.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.eti-sre-imagebuilder.id
  versioning_configuration {
    status = "Enabled"
  }
}
