module "rds" {
  source            = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-aurora-postgres?ref=1.1.0"
  vpc_name          = local.vpc_name
  database_name     = "cnapp_k8s_service"
  db_instance_type  = "db.r5.xlarge"
  cluster_name      = local.rds_name
  secret_path       = "secret/eticcprod/infra/aurora-pg/eu-west-1/cwpp-staging/rds-cwpp-staging-1"
  db_allowed_cidrs  = [data.aws_vpc.cluster_vpc.cidr_block]
  db_engine_version = "15"
}