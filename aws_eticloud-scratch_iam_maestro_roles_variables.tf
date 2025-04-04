variable "tags" {
  type = map(any)
  default = {
    DataClassification = "CiscoConfidential"
    DataTaxonomy       = "CiscoOperationsData"
    CiscoMailAlias     = "eti-sre_at_cisco_dot_com"
    ApplicationName    = "eticloud-scratch-maestro-iam"
    Environment        = "NonProd"
    ResourceOwner      = "ETI SRE and Maestro"
  }
}