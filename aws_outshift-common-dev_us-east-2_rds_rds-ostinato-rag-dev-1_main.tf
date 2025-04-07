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

module "rds" {
  source            = "git::https://github.com/cisco-eti/sre-tf-module-aws-aurora-postgres?ref=1.1.0"
  vpc_name          = local.vpc_name
  database_name     = "rag"
  db_instance_type  = "db.r7g.xlarge"
  cluster_name      = local.rds_name
  secret_path       = "secret/eticcprod/infra/aurora-pg/us-east-2/outshift-common-dev/ostinato-rag-dev-1"
  db_allowed_cidrs  = [data.aws_vpc.cluster_vpc.cidr_block]
  db_engine_version = "15"
}
