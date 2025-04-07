# Atlantis has credentials to the eticloud AWS account. It uses those credentials to store and retrieve state information.
# `Path=` specifies the path to credentials in Keeper. The assumed namespace is eticloud/eticcprod.
# This data call is required for all accounts. The two current options are "scratch" (as below) and "prod".
data "vault_generic_secret" "aws_infra_credential" {
  path="secret/eticcprod/infra/prod/aws"
}

terraform {
  backend "s3" {
    bucket        = "eticloud-tf-state-nonprod" # Do not change without talking to the SRE team.
    key           = "terraform-state/documentdb/us-east-2/docdb-dev-1/docdb-dev-1.tfstate" # The statefile name should be descriptive and must be unique.
    region        = "us-east-2" # Do not change without talking to the SRE team.
  }
}

variable "nonprod_db_vpc_id" {
  description     = "Requester VPC ID"
  default         = "vpc-03f81c8d73fcfaed4"
}

variable "AWS_INFRA_REGION" {
  description     = "AWS Region"
  default         = "us-east-2"
}

# By setting the AWS provider credentials via the data source above, we control in which account and region the resources get created.
provider "aws" {
  access_key      = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key      = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region          = var.AWS_INFRA_REGION
  max_retries     = 3
}

data "vault_generic_secret" "docdb_credentials" {
  path="secret/eticcprod/infra/docdb/us-east-2/docdb-dev-1"
}
resource "aws_docdb_subnet_group" "nonprod_docdb_sg" {
  name       = "nonprod-vpc-docdb-subnet-group"
  subnet_ids = ["subnet-0df57bf95528fc84a", "subnet-0c2a472a177630a0b", "subnet-036bad1ca3048ae63"]

  tags = {
    Name = "Nonprod DocumentDB Subnet Group"
    CSBApplicationName = "nonprod-db-vpc-subnet-group"
    CSBCiscoMailAlias = "eti-sre@cisco.com"
    CSBDataClassification = "Cisco Confidential"
    CSBDataTaxonomy = "Cisco Operations Data"
    CSBEnvironment = "NonProd"
    CSBResourceOwner = "ETI SRE"
  }
}
resource "aws_kms_key" "docdb_kms" {
  description             = "DocDB Dev 1 KMS key"
}
resource "aws_docdb_cluster" "docdb" {
  cluster_identifier              = "docdb-dev-1"
  engine                          = "docdb"
  master_username                 = data.vault_generic_secret.docdb_credentials.data["master_username"]
  master_password                 = data.vault_generic_secret.docdb_credentials.data["master_password"]
  backup_retention_period         = 30
  preferred_backup_window         = "07:00-09:00"
  db_subnet_group_name            = aws_docdb_subnet_group.nonprod_docdb_sg.id
  enabled_cloudwatch_logs_exports = ["audit"]
  deletion_protection             = "true"
  engine_version                  = "4.0.0"
  skip_final_snapshot             = "true"
  storage_encrypted               = "true"
  kms_key_id                      = aws_kms_key.docdb_kms.arn
  tags = {
    Name = "Maestro DocumentDB Dev 1"
    CSBApplicationName = "docdb-dev-1"
    CSBCiscoMailAlias = "eti-sre@cisco.com"
    CSBDataClassification = "Cisco Confidential"
    CSBDataTaxonomy = "Cisco Operations Data"
    CSBEnvironment = "NonProd"
    CSBResourceOwner = "ETI SRE"
  }
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "docdb-dev-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.r5.large"

  tags = {
    Name = "Maestro DocumentDB Dev Instances"
    CSBApplicationName = "docdb-dev-1"
    CSBCiscoMailAlias = "eti-sre@cisco.com"
    CSBDataClassification = "Cisco Confidential"
    CSBDataTaxonomy = "Cisco Operations Data"
    CSBEnvironment = "NonProd"
    CSBResourceOwner = "ETI SRE"
  }
}
