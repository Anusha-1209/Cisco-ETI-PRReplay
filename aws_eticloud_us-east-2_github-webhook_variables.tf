variable "appname_prefix" {
  description = "App Name Prefix"
  type = string
  default = "github-webhook"
}

variable "lambda_function_name" {
  description = "Lambda Function Name"
  type = string
  default = "github-webhook-lambda"
}
variable "lambda_invocation_threshold" {
  description = "Innocation alarm Threshold for number of events in a 5 minute period."
  type = string
  default = 2000
}

variable "region" {
  description = "AWS Default Region"
  type = string
  default = "us-east-2"
}

variable "accountId" {
  description = "AWS Account ID"
  type = string
  default = "626007623524"
}

variable "env" {
  description = "Environment"
  type = string
  default = "prod"
}

variable "DataClassification" {
  description = "Tag DataClassification"
  type = string
  default = "Cisco Confidential"
}

variable "Environment" {
  description = "Tag Environment"
  type = string
  default = "Prod"
}

variable "ApplicationName" {
  description = "Tag ApplicationName"
  type = string
  default = "GithubWebhook"
}

variable "ResourceOwner" {
  description = "Tag ResourceOwner"
  type = string
  default = "ETI SRE"
}

variable "CiscoMailAlias" {
  description = "Tag CiscoMailAlias"
  type = string
  default = "eti-sre-admins@cisco.com"
}

variable "DataTaxonomy" {
  description = "Tag DataTaxonomy"
  type = string
  default = "Cisco Operations Data"
}
