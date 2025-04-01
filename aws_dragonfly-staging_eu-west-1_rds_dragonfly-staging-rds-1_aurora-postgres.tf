module "rds" {
  source            = "git::https://github.cisco.com/cisco-eti/sre-tf-module-aws-aurora-postgres?ref=1.0.7"
  vpc_name          = "dragonfly-data-staging-1-vpc"
  database_name     = "dragonflywheel"
  db_instance_type  = "db.r5.xlarge"
  db_engine_version = "13.11"
  secret_path       = "secret/eticcprod/infra/aurora-pg/eu-west-1/rds-dragonfly-staging-1"
  cluster_name      = "rds-dragonfly-staging-1"
  db_allowed_cidrs = [
    data.aws_vpc.msk_vpc.cidr_block,
    data.aws_vpc.eks_vpc.cidr_block,
  ]
}
