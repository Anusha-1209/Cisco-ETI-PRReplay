terraform {
  required_version = ">= 1.5.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.38"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.65.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
  }
}
