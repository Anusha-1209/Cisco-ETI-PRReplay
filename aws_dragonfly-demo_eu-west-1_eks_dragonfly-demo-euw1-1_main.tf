terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-prod"
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/dragonfly-demo/eu-west-1/eks/dragonfly-demo-1-euw1-1.tfstate"
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2" # DO NOT CHANGE.
  }
}

locals {
  source_cluster_name             = "dragonfly-demo-euw1-1"
  target_cluster_name = "dragonfly-tgt-euw1-1"
  region           = "eu-west-1"
  aws_account_name = "dragonfly-demo"
  aws_iam_cred_secret_name = "ast-aws-iam-credentials"
  aws_iam_cred_secret_namespace = "argo"
  account_id = "545452251603"

}

module "eks_all_in_one" {
  # EKS cluster partially created as of Jan 15 2024
  source = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=latest"

  name             = local.source_cluster_name             # EKS cluster name
  region           = local.region           # AWS provider region
  aws_account_name = local.aws_account_name # AWS account name
  cidr             = "10.3.0.0/16"          # VPC CIDR
  cluster_version  = "1.28"                 # EKS cluster version

  # EKS Managed Private Node Group
  ami_type                   = "AMAZON_LINUX_2"# EKS AMI type, required in case non hardened images
  skip_cisco_hardened_ami    = true            # Skip cisco hardened images
  instance_types             = ["m5a.2xlarge"] # EKS instance types, prod US uses m5a.2xlarge
  min_size                   = 5               # EKS node group min size
  max_size                   = 10              # EKS node group max size
  desired_size               = 6               # EKS node group desired size

  additional_aws_auth_configmap_roles = [
      {
        rolearn  = aws_iam_role.dragonfly-cast-cluster-access_role.arn,
        username = "dragonfly-cast-cluster-access",
        groups   = ["system:masters"]
      }
  ]
}

resource "aws_iam_role" "dragonfly-cast-cluster-access_role" {
  name = "dragonfly-cast-cluster-access"

  assume_role_policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : "sts:AssumeRole",
          Principal: {
            "AWS": aws_iam_user.dragonfly-cast-cluster-access_user.arn
          }
        }
      ]
    })


  inline_policy {
    name = "dragonfly-cast-cluster-access"
    policy = jsonencode({
    Statement: [
        {
            Action: [
                "eks:DescribeCluster"
            ],
            Effect: "Allow",
            Resource: "arn:aws:iam::${local.account_id}:cluster/${local.source_cluster_name}",
            Sid: "1"
        },
        {
            Action: [
                "eks:DescribeCluster"
            ],
            Effect: "Allow",
            Resource: "arn:aws:iam::${local.account_id}:cluster/${local.target_cluster_name}",
            Sid: "2"
        }
    ],
    Version: "2012-10-17"
    })  
  }

}

resource "aws_iam_user" "dragonfly-cast-cluster-access_user" {
  name = "dragonfly-cast-cluster-access"
}

resource "aws_iam_access_key" "dragonfly-cast-cluster-access_user_access_key" {
  user = aws_iam_user.dragonfly-cast-cluster-access_user.name
}

resource "kubernetes_secret" "dragonfly-cast-cluster-access-aws-cred-secret" {
  metadata {
    name = local.aws_iam_cred_secret_name
    namespace = local.aws_iam_cred_secret_namespace
  }

  string_data = {
    "AWS_ACCESS_KEY_ID" = aws_iam_access_key.dragonfly-cast-cluster-access_user_access_key.id
    "AWS_SECRET_ACCESS_KEY" = aws_iam_access_key.dragonfly-cast-cluster-access_user_access_key.encrypted_secret
  }
}
