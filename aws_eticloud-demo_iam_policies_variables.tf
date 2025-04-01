variable "tags" {
  type = map(any)
  default = {
    DataClassification = "CiscoConfidential"
    DataTaxonomy       = "CiscoOperationsData"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    ApplicationName    = "eticloud-demo"
    Environment        = "NonProd"
    ResourceOwner      = "Nandu Mallapragada"
  }
}