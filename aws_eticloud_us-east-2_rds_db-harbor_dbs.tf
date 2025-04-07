terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.15.0"
    }
  }
}
# Random password for Harbor user
resource "random_password" "harbor" {
  length    = 24
  special   = false
}

# Pulling AWS credentials from Keeper
data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/eticcprod/infra/prod/aws"
}
data "vault_generic_secret" "db_info" {
  path = "secret/eticcprod/infra/aurora-pg/us-east-2/harbor01/connection"
}
# Describes the statefile and table in the eticloud aws account. Each Atlantis project should have it's own statefile (key)
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"                                       # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key    = "terraform-state/databases/us-east-2/harbor-databases.tfstate" #note the path here. It should match the patten terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                                    #do not change
  }
}



variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-east-2"
}

# By setting the AWS provider credentials via the data source above, we control in which account and region the resources get created.
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.AWS_INFRA_REGION
  max_retries = 3
}

# More info on postgresql TF resources: https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/postgresql_database


provider "postgresql" {
  host     = data.vault_generic_secret.db_info.data["cluster_write_endpoint"]
  username = data.vault_generic_secret.db_info.data["cluster_master_username"]
  port     = data.vault_generic_secret.db_info.data["cluster_port"]
  scheme   = "awspostgres"
  alias = "pgh"
}

resource "postgresql_database" "core" {
  provider = postgresql.pgh
  name              = "harbor01_core"
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
}

resource "postgresql_database" "notaryserver" {
  provider = postgresql.pgh
  name              = "harbor01_notaryserver"
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
}

resource "postgresql_database" "notarysigner" {
  provider = postgresql.pgh
  name              = "harbor01_notarysigner"
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
}

resource "postgresql_role" "harbor" {
  provider = postgresql.pgh
  name             = "harbor01_user"
  login            = true
  connection_limit = -1
  password         = random_password.harbor.result
}

resource "postgresql_grant" "harbor_grants_core" {
  provider = postgresql.pgh
  database    = postgresql_database.core.name
  role        = postgresql_role.harbor.name
  object_type = "database"
  schema      = "PUBLIC"
  privileges  = ["ALL"]
}

resource "postgresql_grant" "harbor_grants_notaryserver" {
  provider = postgresql.pgh
  database    = postgresql_database.notaryserver.name
  role        = postgresql_role.harbor.name
  object_type = "database"
  schema      = "PUBLIC"
  privileges  = ["ALL"]
}

resource "postgresql_grant" "harbor_grants_notarysigner" {
  provider = postgresql.pgh
  database    = postgresql_database.notarysigner.name
  role        = "harbor_notarysigner"
  object_type = "database"
  schema      = "PUBLIC"
  privileges  = ["ALL"]
}

resource "postgresql_grant_role" "harbor_core" {
  provider = postgresql.pgh
  role       = "harbor01_user"
  grant_role = "harbor_core"
}


resource "postgresql_grant_role" "harbor_notaryserver" {
  provider = postgresql.pgh
  role       = "harbor01_user"
  grant_role = "harbor_server"
}

resource "postgresql_grant_role" "harbor_notarysigner" {
  provider = postgresql.pgh
  role       = "harbor01_user"
  grant_role = "harbor_notarysigner"
}

resource "vault_generic_secret" "harbor_role_password" {
  path = "secret/eticcprod/infra/database/${var.AWS_INFRA_REGION}/harbor"
  data_json = jsonencode({
    username = "harbor01_user"
    password = random_password.harbor.result
  })
}
