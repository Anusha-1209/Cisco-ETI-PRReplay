data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/eks/${local.name}/aws"
  provider = vault.eticloud_eticcprod
}

data "aws_vpc" "cluster_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}