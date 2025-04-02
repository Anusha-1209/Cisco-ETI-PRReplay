data "aws_kms_key" "rds_secondary" {
  key_id = ""
}

data "aws_db_subnet_group" "db_subnet_secondary" {
  name = "motf-staging-usw2-data-db-subnet-group"
}

resource "aws_rds_cluster" "headless_secondary" {
  global_cluster_identifier = ""
  cluster_identifier        = "motf-staging-usw2-headless"
  source_region             = "us-east-2"

  engine                              = "aurora-postgres"
  kms_key_id                          = data.aws_kms_key.rds_secondary.arn
  db_subnet_group_name                = data.aws_db_subnet_group.db_subnet_secondary.name
  iam_database_authentication_enabled = true
}
