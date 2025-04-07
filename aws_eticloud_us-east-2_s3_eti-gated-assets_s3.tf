terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0, >= 3.38.0" # 3.38.0 adds tag propagation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/resource-tagging#propagating-tags-to-all-resources
    }
  }
  backend "s3" {
    bucket         = "eticloud-tf-state-nonprod"
    key            = "backend/sre/eti-gated-assets-dev.tfstate"
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

# designated bucket for demo/hello-world apps
resource "aws_s3_bucket" "eti-gated-assets-dev" {
  bucket = "eti-gated-assets-dev"
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
    Name               = "eti-gated-assets"
    ApplicationName    = "Websites"
    Environment        = "NonProd"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Strategic Data"
  }
}
