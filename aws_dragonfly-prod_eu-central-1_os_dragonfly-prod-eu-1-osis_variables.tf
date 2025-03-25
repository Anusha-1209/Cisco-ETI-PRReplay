variable "pipeline_name" {
  description = "The name of the pipeline"
  type        = string
  default     = "osis-dragonfly-prod-eu-1-kafka"
}

variable "domain_name" {
  description = "The name of the domain"
  type        = string
  default     = "os-dragonfly-prod-eu-1"
}

variable "msk_cluster_name" {
  description = "The name of the MSK cluster"
  type        = string
  default     = "dragonfly-msk-prod-eu-1"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    ApplicationName    = "osis-dragonfly-prod-eu-1"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "Prod"
    ResourceOwner      = "ETI SRE"
  }
}
