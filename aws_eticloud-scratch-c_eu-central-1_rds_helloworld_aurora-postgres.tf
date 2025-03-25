module "rds" {
  source            = "git::https://github.com/cisco-eti/sre-tf-module-aws-aurora-postgres?ref=1.1.0"
  vpc_name          = "daboucha-liquibase-2"
  database_name     = "helloworld"
  db_instance_type  = "db.t4g.micro"
  cluster_name      = "helloworld"
  db_engine_version = "15"
  db_allowed_cidrs  = ["10.19.0.0/16"] # EKS VPC CIDR
  secret_path       = "secret/eticcprod/infra/aurora-pg/eu-central-1/helloworld"
}
