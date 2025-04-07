terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0, >= 3.38.0" # 3.38.0 adds tag propagation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/resource-tagging#propagating-tags-to-all-resources
    }
  }

  backend "s3" {
    bucket         = "eticloud-tf-state"
    key            = "backend/terraform-state-buckets.tfstate"
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
      CiscoMailAlias  = "eti-sre_at_cisco_dot_com"
      ApplicationName = "SRE Terraform"
      ResourceOwner   = "ETI SRE"
    }
  }
}

# store states for resources in scratch/sandbox envs
resource "aws_s3_bucket" "eticloud-tf-state-sandbox" {
  bucket = "eticloud-tf-state-sandbox"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 7
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
    Name               = "eticloud-tf-state-sandbox"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "Sandbox"
  }
}

# store states for resources in dev/staging envs
resource "aws_s3_bucket" "eticloud-tf-state-nonprod" {
  bucket = "eticloud-tf-state-nonprod"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 7
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
    Name               = "eticloud-tf-state-nonprod"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
  }
}

# store states for resources in production-level envs
resource "aws_s3_bucket" "eticloud-tf-state-prod" {
  bucket = "eticloud-tf-state-prod"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 7
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
    Name               = "eticloud-tf-state-prod"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "Prod"
  }
}
