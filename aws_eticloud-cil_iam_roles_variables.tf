variable "tags" {
  type = map(any)
  default = {
    DataClassification = "CiscoConfidential"
    DataTaxonomy       = "CiscoOperationsData"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    ApplicationName    = "CIL"
    Environment        = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
}