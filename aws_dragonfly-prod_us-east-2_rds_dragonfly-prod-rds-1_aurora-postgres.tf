module "rds" {
  source            = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-aurora-postgres?ref=1.0.7"
  vpc_name          = "dragonfly-data-prod-1-vpc"
  database_name     = "dragonfly"
  db_instance_type  = "db.r5.xlarge"
  cluster_name      = "dragonfly-rds-prod-1"
  db_engine_version = "13.11"
  secret_path       = "secret/eticcprod/infra/aurora-pg/us-east-2/dragonfly-rds-prod-1"
  db_allowed_cidrs = [
    data.aws_vpc.eks_vpc.cidr_block,
  ]
}
