module "rds" {
  source            = "git::https://github.com/cisco-eti/sre-tf-module-aws-aurora-postgres?ref=1.1.0"
  vpc_name          = "daboucha-liquibase-2"
  database_name     = "liquibaserds1"
  db_instance_type  = "db.t4g.medium"
  cluster_name      = "liquibaserds1"
  db_engine_version = "15.4"
  db_allowed_cidrs  = ["10.19.0.0/16"] # EKS VPC CIDR, not needed since the DB will live in the same VPC as the EKS cluster
  secret_path       = "secret/eticcprod/infra/aurora-pg/eticloud-scratch-c/eu-central-1/liquibase-rds-1"
}

resource "aws_db_subnet_group" "aurora_db_subnet_group" {
  name = "daboucha-liquibase-2-db-subnet-group"
  # intra subnets in the EKS VPC
  subnet_ids = ["subnet-0ef13dfb2335a2612", "subnet-05a5f12ba469f9280", "subnet-026ebd609e59b2072"]

  tags = {
    Name = "DB subnet group to bootstrap an RDS instance in an existing VPC"
  }
}
