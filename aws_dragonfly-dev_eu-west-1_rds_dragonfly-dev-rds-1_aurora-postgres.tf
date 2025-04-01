module "rds" {
  source            = "git::https://github.com/cisco-eti/sre-tf-module-aws-aurora-postgres?ref=1.0.7"
  vpc_name          = "dragonfly-data-vpc"
  database_name     = "dragonflywheel"
  db_instance_type  = "db.r5.xlarge"
  cluster_name      = "dragonfly-rds-1"
  db_engine_version = "13.11"
  secret_path       = "secret/eticcprod/infra/aurora-pg/eu-west-1/dragonfly-rds-1"
  db_allowed_cidrs = [
    data.aws_vpc.eks_vpc.cidr_block,
  ]
}
