provider "vault" {
  alias     = "eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}
provider "vault" {
  alias = "eticloud"
  address = "https://keeper.cisco.com"
  namespace = "eticloud"
}
provider "vault" {
  alias = "rosey"
  address = "https://keeper.cisco.com"
  namespace = "eticloud/apps/rosey"
}
# Change `path = "secret/eticcprod/infra/<account_name>/aws" to specify the account in which the resources will be created. 
# Must match the account in which the VPC was created.
data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/rosey-test/terraform-admin"
  provider = vault.eticloud
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"                                                           # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key    = "terraform-state/rosey-test/eks/eu-west-1/rosey-staging-euw1-1-eso.tfstate" # Note the path here. It should match the patten terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                                                        # Do not change
    # profile = "eticloud" # if you are doing developing Terraform, you can specify a local profile to use for accessing the statefile ONLY. A CLI login to Keeper is also required.
  }
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "3.23.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "5.31.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.25.2"
    }
  }
}

# Infra AWS Provider
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "eu-central-1"
  max_retries = 3
  default_tags {
    # These tags are required for security compliance. For more information on Data Classification and Data Taxonomy, please talk to the SRE team.
    tags = {
      DataClassification = "Cisco Restricted"
      Environment        = "NonProd"
      ApplicationName    = "rosey-staging-euw1-1-eso"
      ResourceOwner      = "eti sre"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataTaxonomy       = "Cisco Operations Data"
    }
  }
}

locals {
  cluster_name = "rosey-staging-euw1-1"
}

data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

data "vault_generic_secret" "cluster_certificate" {
  path = "secret/infra/eks/rosey-staging-euw1-1/certificate"
  provider = vault.eticloud
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  token                  = data.aws_eks_cluster_auth.cluster.token
  alias                  = "rosey-staging-euw1-1"
}

# vault kubernetes auth backend in rosey

resource "vault_auth_backend" "rosey" {
  type        = "kubernetes"
  description = "Kubernetes Authentication Backend for the cluster ${local.cluster_name}"
  path        = local.cluster_name
  provider    = vault.rosey
}

resource "vault_kubernetes_auth_backend_config" "rosey" {
  backend                = vault_auth_backend.rosey.path
  kubernetes_host        = data.aws_eks_cluster.cluster.endpoint
  kubernetes_ca_cert     = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  provider               = vault.rosey
  issuer                 = "api"
  disable_iss_validation = "true"
}

resource "vault_kubernetes_auth_backend_role" "rosey" {
  backend                          = vault_auth_backend.rosey.path
  role_name                        = "external-secrets-${local.cluster_name}"
  bound_service_account_names      = ["external-secrets-vault"]
  bound_service_account_namespaces = ["external-secrets"]
  token_ttl                        = 3600
  token_policies                   = ["external-secrets-staging"]
  provider                         = vault.rosey
}

resource "vault_policy" "rosey" {
  name = "${local.cluster_name}"
  policy = <<EOT
    # K8s External Secrets Vault Policy

    # Dev secrets
    path "secret/data/dev/*" {
      capabilities = ["read", "list"]
    }
    path "secret/dev/*" {
      capabilities = ["read", "list"]
    }
    path "secret/data/staging/*" {
      capabilities = ["read", "list"]
    }
    path "secret/staging/*" {
      capabilities = ["read", "list"]
    }
    # Atlantis
    path "secret/data/atlantis/*" {
      capabilities = ["read", "list"]
    }
    path "secret/atlantis/*" {
      capabilities = ["read", "list"]
    }
    path "secret/data/keeper-atlantis/*" {
      capabilities = ["read", "list"]
    }
    path "secret/keeper-atlantis/*" {
      capabilities = ["read", "list"]
    }

    # Common secrets
    path "secret/data/common/*" {
      capabilities = ["read", "list"]
    }
    path "secret/common/*" {
      capabilities = ["read", "list"]
    }

    # Panoptica secrets
    path "secret/data/panoptica/staging/*" {
      capabilities = ["read", "list"]
    }
    path "secret/panoptica/staging/*" {
      capabilities = ["read", "list"]
    }
    
    # STO Secrets
    path "secret/data/sto/*" {
      capabilities = ["read", "list"]
    }
    path "secret/sto/*" {
      capabilities = ["read", "list"]
    }

    # Grafana Secrets
    path "secret/data/grafana/*" {
      capabilities = ["read", "list"]
    }
    path "secret/grafana/*" {
      capabilities = ["read", "list"]
    }

    # Harbor secrets
    path "secret/data/harbor/harbor-staging/*" {
      capabilities = ["read", "list"]
    }
    path "secret/harbor/harbor-staging/*" {
      capabilities = ["read", "list"]
    }

    # One-eye secrets
    path "secret/data/one-eye/*" {
      capabilities = ["read", "list"]
    }
    path "secret/one-eye/*" {
      capabilities = ["read", "list"]
    }

    # MSK secrets
    path "secret/data/infra/msk/*" {
      capabilities = ["read", "list"]
    }
    path "secret/infra/msk/*" {
      capabilities = ["read", "list"]
    }
EOT
  provider = vault.rosey
}

# vault kubernetes auth backend in eticloud

resource "vault_auth_backend" "eticloud" {
  type        = "kubernetes"
  description = "Kubernetes Authentication Backend for the cluster ${local.cluster_name}"
  path        = local.cluster_name
  provider    = vault.eticloud
}

resource "vault_kubernetes_auth_backend_config" "eticloud" {
  backend                = vault_auth_backend.eticloud.path
  kubernetes_host        = data.aws_eks_cluster.cluster.endpoint
  kubernetes_ca_cert     = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  provider               = vault.eticloud
  issuer                 = "api"
  disable_iss_validation = "true"
}

resource "vault_kubernetes_auth_backend_role" "eticloud" {
  backend                          = vault_auth_backend.eticloud.path
  role_name                        = "external-secrets-${local.cluster_name}"
  bound_service_account_names      = ["external-secrets-vault"]
  bound_service_account_namespaces = ["external-secrets"]
  token_ttl                        = 3600
  token_policies                   = ["${vault_policy.eticloud.name}"]
  provider                         = vault.eticloud
}

resource "vault_policy" "eticloud" {
  name = "${local.cluster_name}"
  policy = <<EOT
    # K8s External Secrets Vault Policy

    # Dev secrets
    path "secret/data/dev/*" {
      capabilities = ["read", "list"]
    }
    path "secret/dev/*" {
      capabilities = ["read", "list"]
    }
    path "secret/data/staging/*" {
      capabilities = ["read", "list"]
    }
    path "secret/staging/*" {
      capabilities = ["read", "list"]
    }
    # Atlantis
    path "secret/data/atlantis/*" {
      capabilities = ["read", "list"]
    }
    path "secret/atlantis/*" {
      capabilities = ["read", "list"]
    }
    path "secret/data/keeper-atlantis/*" {
      capabilities = ["read", "list"]
    }
    path "secret/keeper-atlantis/*" {
      capabilities = ["read", "list"]
    }

    # Common secrets
    path "secret/data/common/*" {
      capabilities = ["read", "list"]
    }
    path "secret/common/*" {
      capabilities = ["read", "list"]
    }

    # Panoptica secrets
    path "secret/data/panoptica/staging/*" {
      capabilities = ["read", "list"]
    }
    path "secret/panoptica/staging/*" {
      capabilities = ["read", "list"]
    }
    
    # STO Secrets
    path "secret/data/sto/*" {
      capabilities = ["read", "list"]
    }
    path "secret/sto/*" {
      capabilities = ["read", "list"]
    }

    # Grafana Secrets
    path "secret/data/grafana/*" {
      capabilities = ["read", "list"]
    }
    path "secret/grafana/*" {
      capabilities = ["read", "list"]
    }

    # Harbor secrets
    path "secret/data/harbor/harbor-staging/*" {
      capabilities = ["read", "list"]
    }
    path "secret/harbor/harbor-staging/*" {
      capabilities = ["read", "list"]
    }

    # One-eye secrets
    path "secret/data/one-eye/*" {
      capabilities = ["read", "list"]
    }
    path "secret/one-eye/*" {
      capabilities = ["read", "list"]
    }

    # MSK secrets
    path "secret/data/infra/msk/*" {
      capabilities = ["read", "list"]
    }
    path "secret/infra/msk/*" {
      capabilities = ["read", "list"]
    }
EOT
  provider = vault.eticloud
}
