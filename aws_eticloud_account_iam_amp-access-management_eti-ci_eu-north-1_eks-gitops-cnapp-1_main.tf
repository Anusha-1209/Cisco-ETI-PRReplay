module "amp_iam_resources" {
  source = "../../../../modules/iam-amp"

  providers = {
    aws.src = aws.source
    aws.dst = aws.destination
  }

  cluster_name    = var.cluster_name
  cluster_region  = var.cluster_region
  aws_account     = var.aws_account
}
