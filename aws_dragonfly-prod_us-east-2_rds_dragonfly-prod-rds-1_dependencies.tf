data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/eticcprod/infra/dragonfly-production/aws"
  provider = vault.eticloud
}

data "aws_vpc" "eks_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dragonfly-compute-prod-1-vpc"]
  }
}

