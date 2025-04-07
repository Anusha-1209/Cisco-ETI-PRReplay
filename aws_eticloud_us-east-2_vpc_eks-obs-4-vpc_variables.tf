variable "AWS_INFRA_REGION" {
  type        = string
  description = "AWS Region"
  default     = "us-east-2"
}

variable "vpc_cidr" {
  type        = string
  description = <<EOF
  (Required) The CIDR of the VPC. The CIDR should be a /16 RFC1918 CIDR.
  Example: "10.1.0.0/16"
  EOF
  validation {
    condition = can(regex("^[0-9]{0,3}.[0-9]{0,3}.0.0/16", var.vpc_cidr))
    error_message = "Error 'vpc_cidr' must be a /16 RFC1918 CIDR"
  }
}

variable "cluster_name" {
  type        = string
  description = "(Required) The name of an EKS cluster. Allows EKS to create nodes in the public and private subnets via tags."
}

variable "create_database_subnet_group" {
  type        = bool
  description = "(Optional) Whether or not to create a database subnet group. If `true`, var.database_subnets must also be populated. Defaults to `false`."
  default     = false
}

variable "create_elasticache_subnet_group" {
  type        = bool
  description = "(Optional) Whether or not to create an Elasticache subnet group. If `true`, var.elasticache_subnets must be populated. Defaults to `false`."
  default     = false
}

variable "DataClassification" {
  type        = string
  description = <<EOF
    (Required) CSB data classification. Options:
      Cisco Restricted
      Cisco Highly Confidential
      Cisco Confidential
      Cisco Public
  EOF
}

variable "EnvironmentName" {
  type        = string
  description = <<EOF
   (Required) CSB EnvironmentName. Options:
      Prod
      NonProd
      Sandbox
  EOF
}

variable "ApplicationName" {
  type        = string
  description = "(Required) The name of the application. Should include the Venture or Team name."
}

variable "ResourceOwner" {
  type        = string
  description = "(Required) CSB Name of the Cisco BU or IT group who is responsible for the particular component."
}

variable "CiscoMailAlias" {
  type        = string
  description = "(Required) CSB Who to contact in case of any issues with/queries about a particular resource."
}

variable "DataTaxonomy" {
  type        = string
  description = <<EOF
    (Required) CSB Data Taxonomy. Options:
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
}
