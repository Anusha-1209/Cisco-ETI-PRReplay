data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}
data "aws_ami" "eks_default_cisco" {
  owners      = ["849570812361"] # <--- The Cloud 9 AWS account
  most_recent = true

  filter {
    name   = "name"
    values = ["CiscoHardened-EKS${var.cluster_version}${local.cluster_os}-amd64-*"]
  }
}

data "aws_ami" "amazonlinux2_cisco_hardened" {
  owners      = ["849570812361"] # <--- The Cloud 9 AWS account
  most_recent = true

  filter {
    name   = "name"
    values = ["CiscoHardened-AmazonLinux2-amd64-*"]
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.name
  depends_on = [ aws_eks_cluster.this ]
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
