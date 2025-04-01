resource "aws_s3_bucket" "motific-processed-documents" {
#  source      = "git::https://github.com/cisco-eti/sre-tf-module-aws-s3.git?ref=1.0.2"
  bucket = "motific-processed-documents" 
  tags = {
    ApplicationName    = "sre-eks"
    CiscoMailAlias     = "eti-sre@cisco.com"
    DataClassification = "Cisco Restricted"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
    ResourceOwner      = "eti"
}
}
resource "aws_s3_bucket_lifecycle_configuration" "motific-processed-documents" {
  bucket = "motific-processed-documents"
  rule {
    id     = "TTL-policy"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}
