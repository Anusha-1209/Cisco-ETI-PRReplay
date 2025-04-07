resource "aws_docdb_cluster" "docdb" {
  cluster_identifier              = "genie-prod"
  engine_version                  = "5.0.0"
  db_cluster_parameter_group_name = "default.docdb5.0"
  //cluster_members                 = [ "genie-prod" ]
  kms_key_id                      = "arn:aws:kms:us-east-2:626007623524:key/3b5af813-0a95-42ce-8f3d-8a6ea6fac6b9"
  availability_zones              = [ "us-east-2a", "us-east-2b", "us-east-2c" ]
  engine                          = "docdb"
  master_username                 = "genie"
  master_password                 = data.vault_generic_secret.genie_docdb_credential.data["MONGO_DB_PASSWORD"]
  backup_retention_period         = 7
  preferred_backup_window         = "00:00-00:30"
  skip_final_snapshot             = true
  deletion_protection             = true
  storage_encrypted               = true
  db_subnet_group_name            = "prod-db-vpc-1-db-subnet-group"
  vpc_security_group_ids          = ["sg-080de64878164f5ab", aws_security_group.genie-prod-docdb-sg.id ]
  enabled_cloudwatch_logs_exports = [ "audit", "profiler" ]

  depends_on = [ aws_vpc_security_group_ingress_rule.genie-docudb-vpc-sg-ingress-rule ]
}

resource "aws_docdb_cluster_instance" "docdb_instances" {
  count              = 2
  identifier         = "genie-prod-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.r6g.large"
}