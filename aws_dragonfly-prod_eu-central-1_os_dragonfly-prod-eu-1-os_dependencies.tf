data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/dragonfly-prod/terraform_admin"
  provider = vault.eticloud
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

data "aws_db_subnet_group" "db_subnet_group" {
  # this returns 3 subnets where the RDS DB lives, required to create the aws_opensearch_domain
  name = "dragonfly-prod-data-euc1-1-db-subnet-group"
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
