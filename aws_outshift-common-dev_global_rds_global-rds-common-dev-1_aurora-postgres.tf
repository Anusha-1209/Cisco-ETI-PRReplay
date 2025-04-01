terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-nonprod"                                                
    key     = "terraform-state/aws/eticloud/global/rds/global-rds-common-dev-1.tfstate"     
    region  = "us-east-2"                                                                  
  }
}

#
resource "aws_rds_global_cluster" "rds_global" {
  # global RDS cluster aren't tied to a region so the provider should not matter here
  provider                     = aws.primary
  global_cluster_identifier    = "global-rds-common-dev-1"
  database_name                = "postgressql"
  force_destroy                = true
  source_db_cluster_identifier = module.rds_primary.cluster_arn
  depends_on                   = [module.rds_primary]
}

resource "aws_kms_key" "primary" {
  provider     = aws.primary
  description  = "Multi-Region primary key for RDS global"
  multi_region = true
}

resource "aws_kms_replica_key" "secondary" {
  provider        = aws.secondary
  description     = "Multi-Region replica key"
  primary_key_arn = aws_kms_key.primary.arn
}

# Primary region us-east-2
module "rds_primary" {
  providers = {
    aws = aws.primary
  }
  source            = "git::https://github.com/cisco-eti/sre-tf-module-aws-aurora-postgres?ref=2.0.0-rc1"
  vpc_name          = local.data_primary_vpc
  database_name     = "postgressql"
  db_instance_type  = "db.r5.xlarge"
  cluster_name      = "global-rds-common-dev-use2-1"
  kms_key_id        = aws_kms_key.primary.arn
  secret_path       = "secret/dev/infra/aurora-pg/us-east-2/outshift-common-dev/global-rds-common-dev-use2-1"
  db_engine_version = "15.4"
  db_allowed_cidrs  = [ data.aws_vpc.eks_primary_vpc.cidr_block, data.aws_vpc.eks_secondary_vpc.cidr_block ]
}

# Secondary region us-east-2
module "rds_secondary" {
  providers = {
    aws = aws.secondary
  }
  source                    = "git::https://github.com/cisco-eti/sre-tf-module-aws-aurora-postgres?ref=2.0.0-rc1"
  vpc_name                  = local.data_secondary_vpc
  database_name             = null
  global_cluster_identifier = aws_rds_global_cluster.rds_global.id
  is_primary_cluster        = false
  db_instance_type          = "db.r5.xlarge"
  # headless, no instances
  instances                 = {}
  cluster_name              = "global-rds-common-dev-usw2-1"
  kms_key_id                = aws_kms_replica_key.secondary.arn
  secret_path               = "secret/dev/infra/aurora-pg/us-west-2/outshift-common-dev/global-rds-common-dev-usw2-1"
  db_engine_version         = "15.4"
  db_allowed_cidrs          = [ data.aws_vpc.eks_primary_vpc.cidr_block, data.aws_vpc.eks_secondary_vpc.cidr_block ]

  depends_on = [module.rds_primary]
}
