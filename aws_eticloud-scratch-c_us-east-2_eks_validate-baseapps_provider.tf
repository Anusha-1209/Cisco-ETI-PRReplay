# This file was created by Outshift Platform Self-Service automation.
provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/eticloud-scratch-c/terraform_admin"
}

provider "aws" {
  alias       = "eks"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "Self-Service EKS Cluster"
      CiscoMailAlias     = "sraradhy@cisco.com"
      DataClassification = "Cisco Restricted"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "Sri_Aradhyula"
    }
  }
}

data "vault_generic_secret" "argocd_aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/eticloud-preprod/terraform_admin"
}
provider "aws" {
  alias       = "argocd"
  access_key  = data.vault_generic_secret.argocd_aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.argocd_aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "Self-Service EKS Cluster"
      CiscoMailAlias     = "sraradhy@cisco.com"
      DataClassification = "Cisco Restricted"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "Sri_Aradhyula"
    }
  }
}

provider "kubernetes" {
  alias                  = "target"
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "kubernetes" {
  alias                  = "argocd"
  host                   = data.aws_eks_cluster.argocd.endpoint
  cluster_ca_certificate = base64decode(data.vault_generic_secret.argocd_cluster_certificate.data["b64certificate"])
  token                  = data.aws_eks_cluster_auth.argocd.token
}