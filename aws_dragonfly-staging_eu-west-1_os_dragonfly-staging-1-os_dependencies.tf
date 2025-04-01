data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
  provider = vault.eticloud
}

# OS account and region
data "aws_caller_identity" "current" {} # data.aws_caller_identity.current.account_id
data "aws_region" "current" {}          # data.aws_region.current.name

data "aws_vpc" "database_vpc" {
  filter {
    name   = "tag:Name"
    values = [
      local.data_vpc_name
    ]
  }
}

data "aws_subnets" "db_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.database_vpc.id]
  }
  filter {
    name = "tag:Name"
    values = [
      "dragonfly-data-staging-1-vpc-db-${data.aws_region.current.name}*"
    ]
  }
}

data "aws_vpc" "compute_vpc" {
  filter {
    name   = "tag:Name"
    values = [
      local.eks_vpc_name
    ]
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
