provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  path    = "secret/infra/aws/sscs-dev/terraform_admin"
}

terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-nonprod"                           # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key     = "terraform-state/eks/us-east-2/fargate-test.tfstate" #note the path here. It should match the patten terraform_state/<service>/<region>/<name>.tfstate
    region  = "us-east-2"                                        #do not change
  }
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "3.4.0"
    }
  }
}

variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-east-2" #Set the region for the resources to be created.
}


# Infra AWS Provider
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.AWS_INFRA_REGION
  max_retries = 3
  default_tags {
    tags = {
      DataClassification = "Cisco Restricted"
      Environment        = "Prod"
      ApplicationName    = "eks-fargate-cluster"
      ResourceOwner      = "eti sre"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataTaxonomy       = "Cisco Operations Data"
    }
  }
}




module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.eks_name
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true
  enable_cluster_creator_admin_permissions = true

  

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  fargate_profiles = [{
    cluster_name = "eks-fargate-cluster"
    subnet_ids          = module.vpc.private_subnets
    selectors = [{
      namespace = "default"
    },
    {
      namespace = "kube-system",
    },
    {
      namespace = "karpenter"
    }]
  }]
}


# Enabling authentication for admin group

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}


provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "null_resource" "wait_for_eks" {
  provisioner "local-exec" {
    command = "echo 'Module 1 finished. Waiting for 180 seconds...' && sleep 180"
    on_failure = continue
  }

  depends_on = [module.eks]
}

module "eks-auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::710476389780:role/admin"
      username = "admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${local.account_id}:role/KarpenterNodeRole-${var.eks_name}"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]
  depends_on = [null_resource.wait_for_eks]
}

### Restart core DNS on terms of scheduling it on fargate
resource "time_static" "restarted_at" {}

resource "kubernetes_annotations" "example" {
  api_version = "apps/v1"
  kind        = "Deployment"
  metadata {
    name = "coredns"
    namespace = "kube-system"
  }
  template_annotations = {
    "kubectl.kubernetes.io/restartedAt" = time_static.restarted_at.rfc3339
  }
  force = true
  depends_on = [null_resource.wait_for_eks]
}