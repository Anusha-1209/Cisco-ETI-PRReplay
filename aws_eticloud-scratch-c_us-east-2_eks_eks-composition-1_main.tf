data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source                         = "git::https://github.com/cisco-eti/sre-tf-module-eks-composition.git?ref=main"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

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

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # Self managed node groups will not automatically create the aws-auth configmap so we need to
  create_aws_auth_configmap = false
  manage_aws_auth_configmap = false

  eks_managed_node_groups = {

    # EKS Managed Private Node Group
    private-ng = {
      name                        = "${local.name}-private-ng"
      use_name_prefix             = true

      subnet_ids                  = module.vpc.private_subnets

      min_size                    = 3
      desired_size                = 3
      max_size                    = 10

      ami_id                      = data.aws_ami.eks_default_cisco.image_id
      enable_bootstrap_user_data  = true

      pre_bootstrap_user_data     = <<-EOT
        export FOO=bar
      EOT

      post_bootstrap_user_data    = <<-EOT
        echo "Outshift kubelet initialized!"
      EOT

      capacity_type               = "ON_DEMAND" # or "SPOT"
      force_update_version        = true
      instance_types              = ["m6a.large"]

      taints = [
      ]

      update_config = {
       max_unavailable_percentage = 33 # or set `max_unavailable`
      }

      description                 = "${local.name} private managed node group launch template"

      ebs_optimized               = true
      disable_api_termination     = false
      enable_monitoring           = true

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 75
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            kms_key_id            = module.ebs_kms_key.key_arn
            delete_on_termination = true
          }
        }
      }

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }

      create_iam_role               = true
      iam_role_name                 = "${local.name}-private-ng-role"
      iam_role_use_name_prefix      = false
      iam_role_description          = "${local.name} EKS managed node group IAM role"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        additional                         = aws_iam_policy.additional.arn
      }
    }
  }
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "../../../../../modules/eks_composition/vpc"

  name = local.name
  cidr = local.vpc_cidr

  azs                                      = local.azs
  # Subnets for EKS private managed node groups
  private_subnets                          = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  # Subnets for Load Balancers
  public_subnets                           = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  # Subnets for EKS Controlplane
  intra_subnets                            = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# data "aws_ami" "eks_default" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amazon-eks-node-${local.cluster_version}-v*"]
#   }
# }

# data "aws_ami" "eks_default_bottlerocket" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["bottlerocket-aws-k8s-${local.cluster_version}-x86_64-*"]
#   }
# }

data "aws_ami" "eks_default_cisco" {
  owners      = ["849570812361"] # <--- The Cloud 9 AWS account
  most_recent = true

  filter {
    name   = "name"
    values = ["CiscoHardened-EKS${local.cluster_version}${local.cluster_os}-amd64-*"]
  }
}

module "key_pair" {
  source  = "../../../../../modules/eks_composition/key_pair"

  key_name_prefix    = local.name
  create_private_key = true
}

module "ebs_kms_key" {
  source  = "../../../../../modules/eks_composition/ebs_kms_key"

  description = "Customer managed key to encrypt EKS managed node group volumes"

  # Policy
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  key_service_roles_for_autoscaling = [
    # required for the ASG to manage encrypted volumes for nodes
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    # required for the cluster / persistentvolume-controller to create encrypted PVCs
    module.eks.cluster_iam_role_arn,
  ]

  # Aliases
  aliases = ["eks/${local.name}/ebs"]
}

resource "aws_iam_policy" "additional" {
  name        = "${local.name}-additional"
  description = "${local.name} node additional policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
  lifecycle {
    create_before_destroy = true
    ignore_changes = [ description ]
  }
}

resource "vault_generic_secret" "cluster_certficate_data" {
  path      = "secret/infra/eks/${local.name}/certificate"
  data_json = <<EOT
{"b64certificate": "${module.eks.cluster_certificate_authority_data}" }
EOT
}

resource "vault_generic_secret" "aws_auth_sre_cluster_endpoint" {
  path      = "secret/infra/eks/${local.name}/cluster_endpoint"
  data_json = <<EOT
{"cluster_endpoint": "${module.eks.cluster_endpoint}" }
EOT
}

resource "vault_generic_secret" "aws_auth_sre_token" {
  path      = "secret/infra/eks/${local.name}/token"
  data_json = <<EOT
{"token": "${data.aws_eks_cluster_auth.cluster.token}" }
EOT
  lifecycle {
    ignore_changes = [ data_json ]
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}
provider "kubernetes" {
  alias                  = "eks"
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_config_map_v1_data" "aws_auth_sre_data" {
  provider = kubernetes.eks
  force    = true

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_yaml

  depends_on = [ module.eks ]
}