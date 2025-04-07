# staging2 variables
variable "staging2_subdomain" {
  type = string
}
variable "staging2_domain_name" {
  type = string
}
variable "staging2_default_root_object" {
  type    = string
  default = ""
}
variable "staging2_tag_data_classification" {
  type = string
}
variable "staging2_tag_data_taxonomy" {
  type = string
}
variable "staging2_tag_cisco_mail_alias" {
  type = string
}
variable "staging2_tag_application_name" {
  type = string
}
variable "staging2_tag_environment" {
  type = string
}
variable "staging2_tag_resource_owner" {
  type = string
}

