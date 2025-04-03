module "s3" {
  source      = "git::https://github.com/cisco-eti/sre-tf-module-aws-s3.git?ref=1.0.2"
  bucket_name = local.bucket_name

  CSBApplicationName    = local.bucket_name
  CSBCiscoMailAlias     = "eti-sre-admins@cisco.com"
  CSBDataClassification = "Cisco Restricted"
  CSBDataTaxonomy       = "Cisco Operations Data"
  CSBEnvironment        = "NonProd"
  CSBResourceOwner      = "ETI SRE"
}
