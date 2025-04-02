variable "tags" {
  type = map(any)
  default = {
    DataClassification = "CiscoConfidential"
    DataTaxonomy       = "CiscoOperationsData"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    ApplicationName    = "VAE"
    Environment        = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
}