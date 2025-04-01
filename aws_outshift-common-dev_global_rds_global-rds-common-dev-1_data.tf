data "vault_generic_secret" "aws_infra_credential" {
  provider    = vault.eticloud
  path        = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
}

data "aws_vpc" "eks_primary_vpc" {
  provider = aws.primary
  filter {
    name   = "tag:Name"
    values = [local.eks_primary_vpc]
  }
}

data "aws_vpc" "eks_secondary_vpc" {
  provider = aws.secondary
  filter {
    name   = "tag:Name"
    values = [local.eks_secondary_vpc]
  }
}