resource "aws_sagemaker_domain" "motific-e2e" {
  domain_name = local.name
  auth_mode   = "IAM"
  vpc_id      = data.aws_vpc.eks_vpc.id
  subnet_ids  = data.aws_subnets.private.ids

  default_user_settings {
    execution_role = aws_iam_role.motific-e2e.arn
  }
}