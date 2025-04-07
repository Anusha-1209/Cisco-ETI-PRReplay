provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/apisec-dev/terraform_admin"
  provider = vault.eticloud
}

terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-nonprod"
    key     = "terraform-state/aws-apisec-dev/eks/us-east-2/apisec-dev-1-eks-custom-networking.tfstate"
    region  = "us-east-2"
  }
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "3.4.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.21.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-2"
  default_tags {
    tags = {
      ApplicationName    = "apisec-dev-1"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "NonProd"
      ResourceOwner      = "ETI SRE"
    }
  }
}

data "vault_generic_secret" "cluster_certificate" {
  path = "secret/infra/eks/apisec-dev-1/certificate"
}

data "aws_eks_cluster" "cluster" {
  name = "apisec-dev-1"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "apisec-dev-1"
}

data "aws_vpc" "cluster_vpc" {
  filter {
    name   = "tag:Name"
    values = ["apisec-dev-1-vpc"]
  }
}

data "aws_security_group" "vpc_default" {
  vpc_id = data.aws_vpc.cluster_vpc.id

  filter {
    name   = "tag:Name"
    values = ["*vpc-default"]
  }
}
data "aws_security_group" "node_group" {
    vpc_id = data.aws_vpc.cluster_vpc.id
    filter {
        name = "tag:Name"
        values = ["apisec-dev-1-node"]
    }
}
data "aws_subnets" "secondary" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.cluster_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["apisec-dev-1-vpc-secondary-private*"]
  }
}

data "aws_subnet" "these" {
  for_each = toset(data.aws_subnets.secondary.ids)

  id = each.key
}

locals {
  az_subnets = {
    for s in data.aws_subnet.these : s.id => s.availability_zone
  }
  karpenter_sgs = ["${data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id}", "${data.aws_security_group.vpc_default.id}", "${data.aws_security_group.node_group.id}"]
  set_ksgs = toset(local.karpenter_sgs)
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  token                  = data.aws_eks_cluster_auth.cluster.token
  alias                  = "eks"
}

resource "kubernetes_manifest" "eniconfig" {
  provider = kubernetes.eks
  for_each = local.az_subnets

  manifest = yamldecode(<<YAML
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
  name: ${each.value}
spec:
  securityGroups:
    - ${data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id}
    - ${data.aws_security_group.vpc_default.id}
  subnet: ${each.key}
YAML
  )
}
resource "kubernetes_env" "enable_custom_networking" {
  provider  = kubernetes.eks
  container = "aws-node"
  metadata {
    name      = "aws-node"
    namespace = "kube-system"
  }

  api_version = "apps/v1"
  kind        = "DaemonSet"

  env {
    name  = "AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG"
    value = "true"
  }
  env {
    name  = "ENI_CONFIG_LABEL_DEF"
    value = "topology.kubernetes.io/zone"
  }
  force = true
}


output "set_ksgs" {
    value = local.set_ksgs
}
resource "aws_ec2_tag" "karpenter_discovery" {
    for_each = toset(local.karpenter_sgs)
    resource_id = "${each.value}"
    key = "karpenter.sh/discovery"
    value = "apisec-dev-1"
}
