terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/docdb/us-east-2/iam-dashboard-prod-1-docdb.tfstate"
    region = "us-east-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.22.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.21.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3

  default_tags {
    tags = {
      ApplicationName    = "Outshift Identity"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment    = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}

provider "vault" {
    alias = "eticcprod"
    address = "https://keeper.cisco.com"
    namespace = "eticloud/eticcprod"
}

provider "vault" {
  alias     = "eti_identity"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/apps/eti-identity"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path     = "secret/eticcprod/infra/prod/aws"
}

data "vault_generic_secret" "genie_docdb_credential" {
  path     = "secret/prod/iam-dashboard"
  provider = vault.eti_identity
}

data "aws_vpc" "db_vpc" {
  filter {
    name   = "tag:Name"
    values = ["prod-db-vpc-1"]
  }
}

data "aws_vpc" "eks_vpc" {
  filter {
    name   = "tag:Name"
    values = ["eks-prod-3"]
  }
}


resource "aws_security_group" "iam_dashboard_prod_docdb" {
  name        = "iam-dashboard-prod-docdb"
  description = "Allow inbound traffic from eks-prod-3 to iam-dashboard prod docdb"
  vpc_id      = data.aws_vpc.db_vpc.id

  tags = {
    "Name" = "iam-dashboard-prod-docdb-sg"
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.eks_vpc.cidr_block]
  }
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier = "iam-dashboard-prod-1"

  engine                          = "docdb"
  engine_version                  = "5.0.0"
  db_cluster_parameter_group_name = "default.docdb5.0"
  cluster_members = [
    "iam-dashboard-prod-1"
  ]

  vpc_security_group_ids = [
    "sg-080de64878164f5ab", // DB VPC default security group
    aws_security_group.iam_dashboard_prod_docdb.id
  ]
  availability_zones = [
    "us-east-2a",
    "us-east-2b",
    "us-east-2c"
  ]
  db_subnet_group_name = "prod-db-vpc-1-db-subnet-group" // DB subnet group

  master_username = "iamdashboard"
  master_password = data.vault_generic_secret.genie_docdb_credential.data["MONGO_DB_PASSWORD"]

  kms_key_id                      = "arn:aws:kms:us-east-2:626007623524:key/3b5af813-0a95-42ce-8f3d-8a6ea6fac6b9"
  storage_encrypted               = true
  backup_retention_period         = 7
  preferred_backup_window         = "00:00-00:30"
  skip_final_snapshot             = true
  deletion_protection             = true
  enabled_cloudwatch_logs_exports = ["audit", "profiler"]

  depends_on = [aws_security_group.iam_dashboard_prod_docdb]
}

resource "aws_docdb_cluster_instance" "docdb_ibstance_1" {
  identifier         = "iam-dashboard-prod-1-1"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.r6g.large"
}
