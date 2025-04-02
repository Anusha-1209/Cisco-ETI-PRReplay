terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key = "terraform-state/aws/outshift-common-dev/us-east-2/msk/glue-events-table-marvin-dev-use2-1.tfstate"
    region = "us-east-2"
  }
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/outshift-common-dev/terraform_admin"
  provider = vault.eticloud
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-2"
  default_tags {
    tags = {
      ApplicationName    = "glue-events-table-marvin-dev-use2-1"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "NonProd"
      ResourceOwner      = "Outshift SRE"
    }
  }
}

resource "aws_glue_catalog_database" "aws_glue_catalog_marvin_database" {
  name = "marvin"
}

resource "aws_glue_catalog_table" "aws_glue_catalog_marvin_table" {
  name          = "events_dev_use2_1"
  database_name = aws_glue_catalog_database.aws_glue_catalog_marvin_database.name

  table_type = "EXTERNAL_TABLE"
  parameters = {
    compression_type  = "none"
    classification = "json"
    type_of_data = "file"
  }

  partition_keys {
    name = "year"
    type = "string"
  }
  partition_keys {
    name = "month"
    type = "string"
  }
  partition_keys {
    name = "day"
    type = "string"
  }
  partition_keys {
    name = "hour"
    type = "string"
  }
  storage_descriptor {
    location      = "s3://msk-connect-marvin-dev-use2-1/topics/events/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "my-stream"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"

      parameters = {
        paths: "actor,actorRole,actorType,additionalInfo,apiEndpoint,apiName,description,eventType,fullModelOutput,inspectorVersion,prompt,reqId,response,result,seqId,tenantId,timestamp,severity,servicename,integrationName"
      }
    }

    columns {
      name = "actor"
      type = "string"
    }

    columns {
      name = "actortype"
      type = "string"
    }

    columns {
      name    = "actorrole"
      type    = "string"
      comment = ""
    }

    columns {
      name    = "prompt"
      type    = "string"
      comment = ""
    }

    columns {
      name    = "seqid"
      type    = "string"
      comment = ""
    }

    columns {
      name    = "reqid"
      type    = "string"
      comment = ""
    }

    columns {
      name    = "apiname"
      type    = "string"
      comment = ""
    }

    columns {
      name    = "apiendpoint"
      type    = "string"
      comment = ""
    }

    columns {
      name    = "promptfullmodeloutput"
      type    = "string"
      comment = ""
    }

    columns {
      name    = "description"
      type    = "string"
      comment = ""
    }

    columns {
      name    = "responsefullmodeloutput"
      type    = "string"
      comment = ""
    }

    columns {
      name    = "timestamp"
      type    = "string"
      comment = ""
    }

    columns {
      name    = "response"
      type    = "string"
      comment = ""
    }

    columns {
      name    = "result"
      type    = "string"
      comment = ""
    }

    columns {
      name    = "eventtype"
      type    = "string"
      comment = ""
    }

    columns {
      name    = "inspectorversion"
      type    = "string"
      comment = ""
    }

    columns {
      name    = "tenantid"
      type    = "string"
      comment = ""
    }

    columns {
      name    = "categories"
      type    = "string"
      comment = ""
    }

    columns {
      name    = "additionalinfo"
      type    = "string"
      comment = ""
    }
    columns {
      name    = "servicename"
      type    = "string"
      comment = ""
    }
    columns {
      name    = "severity"
      type    = "string"
      comment = ""
    }
    columns {
      name    = "integrationName"
      type    = "string"
      comment = ""
    }
  }
}

data "aws_rds_cluster" "marvin-dev-use2-1" {
  cluster_identifier = "marvin-dev-use2-1"
}

data "aws_vpc" "marvin-dev-use2-data" {
  filter {
    name   = "tag:Name"
    values = ["marvin-dev-use2-data"]
  }
}
resource "aws_subnet" "main" {
  vpc_id     = data.aws_vpc.marvin-dev-use2-data.id
#  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "marvin-dev-use2-data-db-us-east-2a"
  }
}

resource "aws_glue_connection" "example" {
  name = "example"
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:postgres://${data.aws_rds_cluster.marvin-dev-use2-1.endpoint}/marvin"
    PASSWORD            = "examplepassword"
    USERNAME            = "exampleusername"
  }
  physical_connection_requirements {
#    availability_zone      = aws_subnet.example.availability_zone
    availability_zone      = data.aws_rds_cluster.marvin-dev-use2-1.availability_zones
    security_group_id_list = [data.aws_rds_cluster.marvin-dev-use2-1.vpc_security_group_ids]
    subnet_id              = data.aws_vpc.marvin-dev-use2-data.
  }
}

// LINKERD fedramp
