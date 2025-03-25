module "rds" {
  source            = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-aurora-postgres?ref=1.1.0"
  vpc_name          = "dragonfly-prod-data-euc1-1"
  database_name     = "dragonfly"
  db_instance_type  = "db.r5.xlarge"
  cluster_name      = "dragonfly-rds-prod-eu1"
  db_engine_version = "13.11"
  secret_path       = "secret/eticcprod/infra/aurora-pg/eu-central-1/dragonfly-rds-prod-eu-1"
  db_allowed_cidrs  = [
    data.aws_vpc.eks_vpc.cidr_block,
  ]
}
