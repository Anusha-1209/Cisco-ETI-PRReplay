data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/dragonfly-staging/terraform_admin"
  provider = vault.eticloud
}

data "aws_vpc" "eks_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dragonfly-compute-staging-1-vpc"]
  }
}

data "aws_vpc" "msk_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dragonfly-data-staging-1-vpc"]
  }
}

data "aws_subnets" "eks_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.eks_vpc.id]
  }
  tags = {
    Tier = "Private"
  }
}

data "aws_subnets" "msk_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.msk_vpc.id]
  }
  tags = {
    Tier = "Private"
  }
}
