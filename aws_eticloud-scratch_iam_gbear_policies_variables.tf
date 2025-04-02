variable "tags" {
  type = map(any)
  default = {
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    CiscoMailAlias     = "eti-sre_at_cisco_dot_com"
    ApplicationName    = "eticloud-gbear-iam"
    Environment        = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
}