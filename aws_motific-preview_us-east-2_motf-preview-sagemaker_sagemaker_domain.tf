resource "aws_sagemaker_domain" "motific-preview" {
  domain_name = local.name
  auth_mode   = "IAM"
  vpc_id      = data.aws_vpc.eks_vpc.id
  subnet_ids  = data.aws_subnets.private.ids

  default_user_settings {
    execution_role = aws_iam_role.motific-preview.arn
  }
}