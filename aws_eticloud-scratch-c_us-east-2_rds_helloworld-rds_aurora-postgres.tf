module "rds" {
  source            = "git::https://github.com/cisco-eti/sre-tf-module-aws-aurora-postgres?ref=1.1.0"
  vpc_name          = "sre-dev-1"
  database_name     = "helloworld"
  db_instance_type  = "db.t4g.micro"
  cluster_name      = "helloworld"
  db_engine_version = "15"
  secret_path       = "secret/eticcprod/infra/aurora-pg/us-east-2/helloworld"
  db_allowed_cidrs  = [
    data.aws_vpc.eks_vpc.cidr_block,
  ]
}
