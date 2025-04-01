variable "tags" {
  type = map
  default = {
    DataClassification = "CiscoConfidential"
    DataTaxonomy       = "CiscoOperationsData"
    CiscoMailAlias     = "eti-sre_at_cisco_dot_com"
    ApplicationName    = "eticloud-great-bear-iam"
    Environment        = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
}