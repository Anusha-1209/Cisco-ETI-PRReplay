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
  assume_role_policy = data.aws_iam_policy_document.sagemaker_assume_role.json
}

