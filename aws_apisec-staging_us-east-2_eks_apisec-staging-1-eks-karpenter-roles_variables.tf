# Common vars
variable "aws_account_credentials_path" {
    type        = string
}

variable "aws_default_region" {
    description = "Change this default to move the VPC into a a different region."
    type        = string
}

variable "environment" {
    type        = string
}

variable "application_name" {
    type        = string
}

# VPC vars

variable "vpc_name" {
    type        = string
}



variable "eks_name" {
    type        = string
  
}
