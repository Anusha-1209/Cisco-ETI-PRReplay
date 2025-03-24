data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["${var.name}-private-*"]
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.key
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["${var.name}-public-*"]
  }
}

data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name   = "name"
        values = ["*ubuntu-jammy-22.04-amd64-server-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"]
}

data "aws_subnet" "target" {
  for_each = "${toset(data.aws_subnets.public.ids)}"
  id       = "${each.value}"
}

data "aws_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
  name   = "default"
}

data "aws_region" "current" {}

# data "aws_ami" "bottlerocket_ami" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["bottlerocket-aws-k8s-${var.cluster_version}-x86_64-*"]
#   }
# }

data "aws_ami" "c9-eks" {
  owners      = ["849570812361"] # <--- The Cloud 9 AWS account
  most_recent = true

  filter {
    name   = "name"
    values = ["CiscoHardened-EKS${var.cluster_version}${var.cluster_os}-amd64-*"]
  }
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
  # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
  arn = data.aws_caller_identity.current.arn
}
