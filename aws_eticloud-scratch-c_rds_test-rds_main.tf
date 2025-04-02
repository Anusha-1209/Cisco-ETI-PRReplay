module "rds" {
  source            = "git::https://github.com/cisco-eti/sre-tf-module-aws-aurora-postgres?ref=1.1.0"
  vpc_name          = local.vpc_name
  database_name     = "postgressql"
  db_instance_type  = "db.r5.xlarge"
  cluster_name      = local.rds_name
  secret_path       = "secret/eticcprod/infra/aurora-pg/us-east-2/eticloud-scratch-c/rds/test-rds-cluster"
  db_allowed_cidrs  = []  # this is a test, not associated to an EKS cluster
  db_engine_version = "15"
}
