data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/dragonfly-prod/terraform_admin"
  provider = vault.eticloud
}

# Get the VPC IDs based on the names of the VPCs
data "aws_vpc" "requestor_vpc" {
  filter {
    name   = "tag:ApplicationName"
    values = ["dragonfly-compute-prod-1"]
  }
}

data "aws_vpc" "acceptor_vpc" {
  filter {
    name   = "tag:ApplicationName"
    values = ["dragonfly-data-prod-1"]
  }
}

data "aws_route_tables" "requestor_vpc_rt" {
  vpc_id = data.aws_vpc.requestor_vpc.id
}

data "aws_route_tables" "acceptor_vpc_rt" {
  vpc_id = data.aws_vpc.acceptor_vpc.id
}

# Use this to get the account ID
data "aws_caller_identity" "current" {}
