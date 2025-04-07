terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0, >= 3.38.0" # 3.38.0 adds tag propagation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/resource-tagging#propagating-tags-to-all-resources
    }
  }
  backend "s3" {
    bucket         = "eticloud-tf-state-prod"
    key            = "backend/sre/eti-identity-static-assets.tfstate"
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
      CiscoMailAlias = "eti-sre-admins@cisco.com"
      ResourceOwner  = "ETI SRE"
    }
  }
}

resource "aws_s3_bucket" "eti-identity-static-assets" {
  bucket = "cisco-eti-identity-static-assets"
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

  # Tags for CSB. More info here:
  # https://cisco.sharepoint.com/Sites/CSB/SitePages/Security%20Tagging%20and%20Audit%20in%20AWS.aspx
  tags = {
    Name               = "cisco-eti-identity-static-assets"
    ApplicationName    = "ETIAM"
    Environment        = "Prod"
    ResourceOwner      = "ETI Identity"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
  }
  lifecycle {
    ignore_changes = [
      tags["CiscoMailAlias"]
    ]
  }
}

resource "aws_s3_bucket_policy" "allow-cloudfront-origin-access-control" {
  bucket = aws_s3_bucket.eti-identity-static-assets.id
  policy = data.aws_iam_policy_document.allow-cloudfront-origin-access-control.json
}

data "aws_iam_policy_document" "allow-cloudfront-origin-access-control" {
  statement {
    sid = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [ "s3:GetObject" ]

    resources = [
      "${aws_s3_bucket.eti-identity-static-assets.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        "arn:aws:cloudfront::626007623524:distribution/E1PFYKOSNMW7BN"
      ]
    }
  }
  statement {
    sid = "AllowCloudFrontServicePrincipalSSE-KMS"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::626007623524:root"]
    }

    actions = [
      "kms:Decrypt"
    ]

    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        "arn:aws:cloudfront::626007623524:distribution/E1PFYKOSNMW7BN"
      ]
    }
  }
}
