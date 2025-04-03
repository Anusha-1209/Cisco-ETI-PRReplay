################################################################################
# TF Backend configuration
################################################################################
terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket  = "eticloud-tf-state-prod"                                                   # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key     = "terraform-state/aws/outshift-common-prod/us-east-2/documentdb/pi-prod-use2-documentdb-2.tfstate"  # UPDATE ME.
    # This is the region where the backend S3 bucket is located.
    region  = "us-east-2"                                                                   # DO NOT CHANGE.
  }
}

################################################################################
# Provider configuration
################################################################################
provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

provider "vault" {
  alias     = "ppu"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/apps/ppu"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/outshift-common-prod/terraform_admin"
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "outshift_common_services"
      Component          = "genie"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "Prod"
      ResourceOwner      = "genie"
    }
  }
}

################################################################################
# DocumentDB
################################################################################
data "vault_generic_secret" "ppu_docdb_credential" {
  path     = "secret/prod/documentdb/db2/backend"
  provider = vault.ppu
}

resource "aws_security_group" "docdb_sg" {
  name        = "pi-prod-use2-documentdb-2-sg"
  description = "Allow inbound traffic from eks-prod-3 to genie prod docdb"
  vpc_id      = "vpc-0621cc8a0dc424f34"
  
  tags        = {
    "Name" = "pi-prod-use2-documentdb-2-sg"
  }

  tags_all    = {
    "Name" = "pi-prod-use2-documentdb-2-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "docdb_sg_rule_1" {
  security_group_id = aws_security_group.docdb_sg.id

  cidr_ipv4   = "10.0.0.0/16"
  ip_protocol = "tcp"
  from_port   = 27017
  to_port     = 27017
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier              = "pi-prod-use2-documentdb-2"
  engine_version                  = "5.0.0"
  db_cluster_parameter_group_name = "default.docdb5.0"
  availability_zones              = ["us-east-2a", "us-east-2b", "us-east-2c"]
  engine                          = "docdb"
  master_username                 = "pi"
  master_password                 = data.vault_generic_secret.ppu_docdb_credential.data["MONGO_DB_PASSWORD"]
  backup_retention_period         = 7
  preferred_backup_window         = "00:00-00:30"
  skip_final_snapshot             = true
  deletion_protection             = true
  storage_encrypted               = true
  db_subnet_group_name            = "pi-prod-use2-data-db-subnet-group"
  vpc_security_group_ids          = ["sg-0675ee3607a38b3c1", aws_security_group.docdb_sg.id]
  enabled_cloudwatch_logs_exports = ["audit", "profiler"]

  depends_on = [aws_security_group.docdb_sg]
}

resource "aws_docdb_cluster_instance" "docdb_instances" {
  count              = 2
  identifier         = "pi-prod-use2-documentdb-2-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.r6g.large"
}
