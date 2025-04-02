module "rds" {
  source            = "git::https://github.com/cisco-eti/sre-tf-module-aws-aurora-postgres?ref=1.1.0"
  vpc_name          = local.vpc_name
  database_name     = "postgres"
  db_instance_type  = "db.r5.xlarge"
  cluster_name      = local.rds_name
  secret_path       = "secret/eticcprod/infra/aurora-pg/us-east-2/motific-preview/motf-preview-use2-1-knowledgebase"
  db_allowed_cidrs  = [data.aws_vpc.cluster_vpc.cidr_block]
  db_engine_version = "15"
}

resource "aws_rds_global_cluster" "motf-preview-knowledgebase-global" {
  global_cluster_identifier    = "motf-preview-knowledgebase-global"
  # (Optional) Enable to remove DB Cluster members from Global Cluster on destroy. Required with source_db_cluster_identifier.
  force_destroy                = true
  source_db_cluster_identifier = module.rds.cluster_arn
}

resource "aws_kms_key" "rds_multi_region_primary" {
  description             = "RDS multi-region primary KMS key for ${local.aws_account_name}"
  multi_region            = true
  enable_key_rotation     = true
}
