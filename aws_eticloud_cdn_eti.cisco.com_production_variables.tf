# prod variables
variable "prod_subdomain" {
  type = string
}
variable "prod_domain_name" {
  type = string
}
variable "prod_default_root_object" {
  type    = string
  default = ""
}
variable "prod_tag_data_classification" {
  type = string
}
variable "prod_tag_data_taxonomy" {
  type = string
}
variable "prod_tag_cisco_mail_alias" {
  type = string
}
variable "prod_tag_application_name" {
  type = string
}
variable "prod_tag_environment" {
  type = string
}
variable "prod_tag_resource_owner" {
  type = string
}