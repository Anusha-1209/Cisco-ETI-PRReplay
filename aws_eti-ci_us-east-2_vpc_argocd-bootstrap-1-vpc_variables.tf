# VPC Module vars
variable "AWS_INFRA_REGION" {
  type        = string
  description = "AWS Infra Region"
  default     = "us-east-2"
}

variable "vpc_name" {
  type        = string
  description = "(Required) VPC name"
}

variable "vpc_cidr" {
  type        = string
  description = "(Required) VPC CIDR sould be a /16 RFC1918 CIDR"
}

variable "create_secondary_subnets" {
  type        = bool
  description = "(Optional) Whether or not to craeet secondary subnets"
}
variable "cluster_name" {
  type        = string
  description = "(Required) The name of an EKS cluster. Allows EKS to create nodes in the public and private subnets via tags"
}

variable "create_database_subnet_group" {
  type        = bool
  description = "(Optional) Whether or not to create a database subnet group. Defaults to `false`."
  default     = false
}

variable "create_elasticache_subnet_group" {
  type        = bool
  description = "(Optional) Whether or not to create an Elasticache subnet group. Defaults to `false`."
  default     = false
}

# Tags
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