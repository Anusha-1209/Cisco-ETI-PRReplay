variable "domain_name" {
  description = "The name of the domain"
  type        = string
  default     = "dragonfly-staging-1-os"
}

variable "msk_cluster_name" {
  description = "The name of the MSK cluster"
  type        = string
  default     = "dragonfly-staging-msk-1"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    ApplicationName    = "osis-dragonfly-staging-1"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
}
