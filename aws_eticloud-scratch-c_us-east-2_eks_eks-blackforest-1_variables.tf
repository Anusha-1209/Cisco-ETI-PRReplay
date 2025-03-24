################################################################################
# CSDL Tagging
################################################################################

variable "application_name" {
  type        = string
  description = "The name of the application."
  default     = "eks-blackforest-1"
}

variable "cisco_mail_alias" {
  type        = string
  description = "Who to contact in case of any issues with/queries about a particular resource."
  default     = "eti-sre-admins@cisco.com"
}
variable "data_classification" {
  type        = string
  description = <<EOF
      Data Classification. Options:
      Cisco Restricted
      Cisco Highly Confidential
      Cisco Confidential
      Cisco Public
  EOF
  default     = "Cisco Confidential"
}
variable "data_taxonomy" {
  type        = string
  description = <<EOF
    Data Taxonomy. Options:
      Administrative Data
      Customer Data
      Entrusted Data
      Financing Data
      Support Data
      Telemetry Data
      Cisco Operations Data
      Cisco Strategic Data
      Human Resources Data
    Defaults to Cisco Operations Data.
  EOF
  default     = "Cisco Operations Data"
}
variable "environment" {
  type        = string
  description = <<EOF
   Environment. Options:
      Prod
      NonProd
      Sandbox
  EOF
  default     = "NonProd"
}
variable "resource_owner" {
  type        = string
  description = "Name of the Cisco BU or IT group who is responsible for the particular component."
  default     = "Outshift SRE"
}