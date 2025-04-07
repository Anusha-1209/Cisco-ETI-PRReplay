terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0, >= 3.38.0" # 3.38.0 adds tag propagation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/resource-tagging#propagating-tags-to-all-resources
    }
  }
  backend "s3" {
    bucket         = "eticloud-tf-state-prod"
    key            = "terraform-state/s3/us-east-2/cisco-eti-racktables-backup-bucket.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region      = "us-east-2"
  max_retries = 3

  default_tags {
    tags = {
      CiscoMailAlias = "eti-sre_at_cisco_dot_com"
      ResourceOwner  = "ETI SRE"
    }
  }
}

resource "aws_s3_bucket" "b" {
  bucket = "cisco-eti-racktables-backup"
  acl    = "private"
  lifecycle_rule {
    id      = "expire-backup-data-after-30-days"
    enabled = true

    prefix = ""

    tags = {
      autoclean = "true"
    }
    expiration {
      days = 30
    }
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
   tags = {  
    DataClassification = "Cisco Confidential"
    Environment        = "Prod"
    ApplicationName    = "ETICloud"
    ResourceOwner      = "ETI SRE"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataTaxonomy       = "Cisco Operations Data"
  }
}