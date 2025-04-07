# staging variables
variable "staging_subdomain" {
  type = string
}
variable "staging_domain_name" {
  type = string
}
variable "staging_default_root_object" {
  type    = string
  default = ""
}
variable "staging_tag_data_classification" {
  type = string
}
variable "staging_tag_data_taxonomy" {
  type = string
}
variable "staging_tag_cisco_mail_alias" {
  type = string
}
variable "staging_tag_application_name" {
  type = string
}
variable "staging_tag_environment" {
  type = string
}
variable "staging_tag_resource_owner" {
  type = string
}

