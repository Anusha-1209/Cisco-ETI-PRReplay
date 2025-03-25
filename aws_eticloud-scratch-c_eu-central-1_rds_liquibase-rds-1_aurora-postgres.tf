module "rds" {
  source            = "git::https://github.com/cisco-eti/sre-tf-module-aws-aurora-postgres?ref=1.1.0"
  vpc_name          = "liquibase-rds-test"
  database_name     = "liquibase-rds-1"
  db_instance_type  = "db.t4g.micro"
  cluster_name      = "liquibase-rds-1"
  db_engine_version = "15"
  db_allowed_cidrs  = ["10.19.0.0/16"] # EKS VPC CIDR
  secret_path       = "secret/eticcprod/infra/aurora-pg/eticloud-scratch-c/eu-central-1/liquibase-rds-1"
}
