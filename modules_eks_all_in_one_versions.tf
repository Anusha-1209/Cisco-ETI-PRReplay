################################################################################
# Terraform version and provider versions
################################################################################

terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.10.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24.0"
    }
    argocd = {
      source = "oboukili/argocd"
      version = "6.0.3"
    }
  }
}