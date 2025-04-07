module "cisco-eti-banzaicloud-kubernetes-charts" {
  source      = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-s3.git?ref=1.0.1"
  bucket_name = "cisco-eti-banzaicloud-kubernetes-charts"

  # Continuous Security Buddy Tags.
  # For more information, see the CSB tagging Sharepoint page here:
  # https://cisco.sharepoint.com/Sites/CSB/SitePages/Security%20Tagging%20and%20Audit%20in%20AWS.aspx
  CSBDataClassification = "Cisco Confidential"
  CSBEnvironment        = "Prod"
  CSBApplicationName    = "ETICloud"
  CSBResourceOwner      = "ETI SRE"
  CSBCiscoMailAlias     = "eti-sre@cisco.com"
  CSBDataTaxonomy       = "Cisco Operations Data"
}
