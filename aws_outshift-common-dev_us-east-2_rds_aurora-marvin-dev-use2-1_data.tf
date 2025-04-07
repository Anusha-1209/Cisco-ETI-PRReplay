data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
  provider = vault.eticloud
}

data "aws_vpc" "cluster_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.cluster_vpc_name]
  }
}
data "aws_vpc" "cluster_vpc_2" { # Add this block
  filter {
    name   = "tag:Name"
    values = [local.cluster_vpc_name_2]
  }
}