variable "domain_name" {
  description = "The name of the domain"
  type        = string
  default     = "os-dragonfly-dev-1"
}

variable "msk_cluster_name" {
  description = "The name of the MSK cluster"
  type        = string
  default     = "dragonfly-msk-1"
}

variable "kakfa_topic" {
  description = "The name of the Kafka topic"
  type        = string
  default     = "test-topic"
}

variable "kakfa_group" {
  description = "The name of the Kafka topic"
  type        = string
  default     = "test-group"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    ApplicationName    = "osis-dragonfly-dev-1"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    EnvironmentName    = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
}
