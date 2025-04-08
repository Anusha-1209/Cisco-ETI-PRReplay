data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/infra/aws/outshift-common-dev/terraform_admin"
}

module "s3_datazone" {
  source      = "git::https://github.com/cisco-eti/sre-tf-module-aws-s3.git?ref=1.0.4"
  bucket_name = "outshift-common-dev-datazone"
  # Continuous Security Buddy Tags.
  # For more information, see the CSB tagging Sharepoint page here:
  # https://cisco.sharepoint.com/Sites/CSB/SitePages/Security%20Tagging%20and%20Audit%20in%20AWS.aspx
  CSBDataClassification = "Cisco Highly Confidential"
  CSBEnvironment        = "NonProd"
  CSBApplicationName    = "DataZone"
  CSBResourceOwner      = "Outshift SRE"
  CSBCiscoMailAlias     = "eti-sre-admins@cisco.com"
  CSBDataTaxonomy       = "Cisco Operations Data"
}


module "dazone_dev" {
  source             = "git::https://github.com/cisco-eti/sre-tf-module-aws-datazone.git?ref=0.1.0"
  create_domain      = true
  domain_name        = "outshift-common-dev"
  domain_description = "DataZone for outshift-common-dev"
  bucket_name        = module.s3_datazone.s3_bucket_id
  project_names      = local.project_names

  depends_on = [module.s3_datazone]
}
