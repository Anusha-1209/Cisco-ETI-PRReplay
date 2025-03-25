data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/dragonfly-prod/terraform_admin"
  provider = vault.eticcprod
}

# OS account and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "database_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dragonfly-prod-data-euc1-1"]
  }
}

data "aws_subnets" "db_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.database_vpc.id]
  }
}

data "aws_vpc" "compute_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dragonfly-prod-euc1-1"]
  }
}

data "aws_subnets" "compute_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.compute_vpc.id]
  }
  tags = {
    Tier = "Private"
  }
}
