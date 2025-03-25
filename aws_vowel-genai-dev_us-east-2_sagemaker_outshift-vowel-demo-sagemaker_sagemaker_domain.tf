locals {
  name                    = "outshift-vowel-demo-sagemaker"
  vpc_name                = "vowel-dev-use2-2"
}

data "aws_vpc" "eks_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.eks_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*${local.vpc_name}-private*"]
  }
}

resource "aws_sagemaker_domain" "vowel-demo" {
  domain_name = local.name
  auth_mode   = "IAM"
  vpc_id      = data.aws_vpc.eks_vpc.id
  subnet_ids  = data.aws_subnets.private.ids

  default_user_settings {
    execution_role = aws_iam_role.vowel-demo.arn
  }
}

resource "aws_iam_role" "vowel-demo" {
  name               = local.name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.vowel-demo.json
}

data "aws_iam_policy_document" "vowel-demo" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}