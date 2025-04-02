module "rds" {
  source            = "git::https://github.com/cisco-eti/sre-tf-module-aws-aurora-postgres?ref=1.1.1"
  vpc_name          = local.vpc_name
  database_name     = "postgressql"
  db_instance_type  = "db.r7g.4xlarge"
  cluster_name      = local.rds_name
  secret_path       = "secret/eticcprod/infra/aurora-pg/us-east-2/motific-prod/motf-prod-use2-1"
  db_allowed_cidrs  = [data.aws_vpc.cluster_vpc.cidr_block]
  db_engine_version = "15"
}

resource "aws_rds_global_cluster" "motf_prod_global" {
  global_cluster_identifier = "motf-prod-1-global"
  # (Optional) Enable to remove DB Cluster members from Global Cluster on destroy. Required with source_db_cluster_identifier.
  force_destroy                = true
  deletion_protection          = true
  source_db_cluster_identifier = module.rds.cluster_arn
  depends_on                   = [module.rds_primary]
}

resource "aws_kms_key" "rds_multi_region_secondary" {
  provider            = aws.secondary
  description         = "RDS multi-region secondary KMS key for ${local.aws_account_name}"
  multi_region        = true
  enable_key_rotation = true
}

resource "aws_kms_key_policy" "rds" {
  provider = aws.secondary
  key_id   = aws_kms_key.rds_multi_region_secondary.id
  policy = jsonencode({
    Id = "rds"
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        }

        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/admin"
        }

        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      }
    ]
    Version = "2012-10-17"
  })
}

module "rds_secondary" {
  providers = {
    aws = aws.secondary
  }
  source                    = "git::https://github.com/cisco-eti/sre-tf-module-aws-aurora-postgres?ref=2.0.4"
  vpc_name                  = local.data_secondary_vpc_name
  database_name             = null
  global_cluster_identifier = aws_rds_global_cluster.motf_prod_global.id
  is_primary_cluster        = false
  master_username           = null
  db_instance_type          = "db.r7g.4xlarge"
  instances = {
    1 = {
      availability_zone = "us-west-2a"
    }
  }
  cluster_name        = "motf-prod-usw2-1"
  kms_key_id          = aws_kms_key.rds_multi_region_secondary.arn
  secret_path         = "secret/staging/infra/aurora-pg/us-west-2/motific-prod/motf-prod-usw2-1"
  db_engine_version   = "15"
  db_allowed_cidrs    = [data.aws_vpc.cluster_vpc.cidr_block]
  skip_final_snapshot = true
}
