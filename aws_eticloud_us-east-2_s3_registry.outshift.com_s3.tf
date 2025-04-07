terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/s3/us-east-1/registry-outshift-com.tfstate"
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
      ApplicationName    = "registry.outshift.com"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}

provider "vault" {
  alias     = "eticloud_eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/eticcprod/infra/prod/aws"
  provider = vault.eticloud_eticcprod
}

data "aws_caller_identity" "current" {}


## S3 Bucket Setup

resource "aws_s3_bucket" "file_storage" {
  bucket        = "registry.outshift.com"
}

## S3 Bucket ACL

resource "aws_s3_bucket_acl" "file_storage" {
  depends_on = [aws_s3_bucket_ownership_controls.file_storage]

  bucket = aws_s3_bucket.file_storage.id
  acl    = "private"
}

## S3 Bucket CORS

resource "aws_s3_bucket_cors_configuration" "file_storage" {
  bucket = aws_s3_bucket.file_storage.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

## S3 Bucket Ownership Controls

resource "aws_s3_bucket_ownership_controls" "file_storage" {
  bucket             = aws_s3_bucket.file_storage.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

## S3 Bucket Block Public Access

resource "aws_s3_bucket_public_access_block" "file_storage" {
  bucket                  = aws_s3_bucket.file_storage.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

## S3 Bucket Versioning

resource "aws_s3_bucket_versioning" "file_storage" {
  bucket = aws_s3_bucket.file_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}