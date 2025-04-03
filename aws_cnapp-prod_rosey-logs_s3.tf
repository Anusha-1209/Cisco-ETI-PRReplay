# https://github.com/hashicorp/terraform/issues/24476
# have to repeat module call due to using 2 providers for each AWS region
module "s3-us" {
  source      = "git::https://github.com/cisco-eti/sre-tf-module-aws-s3.git?ref=1.0.2"
  bucket_name = "rosey-logs-us"
  # Continuous Security Buddy Tags.
  # For more information, see the CSB tagging Sharepoint page here:
  # https://cisco.sharepoint.com/Sites/CSB/SitePages/Security%20Tagging%20and%20Audit%20in%20AWS.aspx
  CSBDataClassification = "Cisco Highly Confidential"
  CSBEnvironment        = "Prod"
  CSBApplicationName    = "rosey-logs-us"
  CSBResourceOwner      = "eti"
  CSBCiscoMailAlias     = "eti-sre@cisco.com"
  CSBDataTaxonomy       = "Cisco Operations Data"
}

resource "aws_s3_bucket_lifecycle_configuration" "rosey_logs_us" {
  provider = aws.us
  bucket   = "rosey-logs-us"
  rule {
    id     = "TTL-policy"
    status = "Enabled"

    expiration {
      days = 7
    }
  }
}
