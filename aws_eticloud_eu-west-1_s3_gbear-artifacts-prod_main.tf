terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0, >= 3.38.0" # 3.38.0 adds tag propagation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/resource-tagging#propagating-tags-to-all-resources
    }
  }
  backend "s3" {
    bucket         = "eticloud-tf-state-prod"
    key            = "terraform-state/s3/eu-west-1/cisco-eti-gbear-artifacts.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region      = "eu-west-1"
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

data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/eticcprod/infra/prod/aws"
}

resource "aws_s3_bucket" "this" {
  bucket = "cisco-eti-gbear-artifacts"
  
  # Tags for CSB. More info here:
  # https://cisco.sharepoint.com/Sites/CSB/SitePages/Security%20Tagging%20and%20Audit%20in%20AWS.aspx
  tags = {
    DataClassification = "Cisco Confidential"
    Environment        = "Prod"
    ApplicationName    = "ETICloud"
    ResourceOwner      = "ETI SRE"
    CiscoMailAlias     = "eti-sre@cisco.com"
    DataTaxonomy       = "Cisco Operations Data"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}
