resource "aws_s3_bucket" "s3" {
  bucket = "cisco-eti-${var.appname_prefix}-${var.env}"

  # Tags for CSB. More info here:
  # https://cisco.sharepoint.com/Sites/CSB/SitePages/Security%20Tagging%20and%20Audit%20in%20AWS.aspx
  tags = {
    DataClassification = var.DataClassification
    Environment        = var.Environment
    ApplicationName    = var.ApplicationName
    ResourceOwner      = var.ResourceOwner
    CiscoMailAlias     = var.CiscoMailAlias
    DataTaxonomy       = var.DataTaxonomy
  }
}

resource "aws_s3_bucket_acl" "s3-acl" {
  bucket = aws_s3_bucket.s3.id
  acl    = "private"
}

resource aws_s3_bucket_versioning s3-versioning {
  bucket = aws_s3_bucket.s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-encryption" {
  bucket = aws_s3_bucket.s3.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}