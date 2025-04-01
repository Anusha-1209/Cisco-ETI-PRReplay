variable "tags" {
  type = map
  default = {
    DataClassification = "CiscoConfidential"
    DataTaxonomy       = "CiscoOperationsData"
    CiscoMailAlias     = "eti-sre_at_cisco_dot_com"
    ApplicationName    = "eticloud-sre-iam"
    Environment        = "Prod"
    ResourceOwner      = "ETI SRE"
  }
}
variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
  default     = "gcp-eticloudscratch-nprd-22453"
}

variable "prefix" {
  type        = string
  description = "Prefix applied to service account names."
  default     = "palladium"
}
