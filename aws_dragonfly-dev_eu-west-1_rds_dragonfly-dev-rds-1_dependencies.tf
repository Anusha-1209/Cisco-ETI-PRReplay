data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/dragonfly-dev/terraform_admin"
  provider = vault.eticloud
}

data "aws_vpc" "eks_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dragonfly-dev-2-vpc"]
  }
}

data "aws_vpc" "demo_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dragonfly-demo-1-vpc"]
  }
}
