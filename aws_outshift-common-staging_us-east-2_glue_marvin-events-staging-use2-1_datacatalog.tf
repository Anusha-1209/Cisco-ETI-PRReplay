terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key = "terraform-state/aws/outshift-common-staging/us-east-2/msk/glue-events-table-marvin-staging-use2-1.tfstate"
    region = "us-east-2"
  }
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/outshift-common-staging/terraform_admin"
  provider = vault.eticloud
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-2"
  default_tags {
    tags = {
      ApplicationName    = "glue-events-table-marvin-staging-use2-1"
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
  name          = "events_staging_use2_1"
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
    location      = "s3://msk-connect-marvin-staging-use2-1/topics/events/"
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
      name    = "integrationname"
      type    = "string"
      comment = ""
    }
  }
}


resource "aws_iam_role" "AWSGlueServiceRoleBatchProcessing" {
  name        = "AWSGlueServiceRoleBatchProcessing"
  description = "IAM Role for GH Actions workflows"
  tags        = {
    ApplicationName    = "AWSGlueServiceRoleBatchProcessing"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "glue.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceRoleBatchProcessingEC2" {
  role       = aws_iam_role.AWSGlueServiceRoleBatchProcessing.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
resource "aws_iam_role_policy_attachment" "AWSGlueServiceRoleBatchProcessingRDSFDA" {
  role       = aws_iam_role.AWSGlueServiceRoleBatchProcessing.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
}
resource "aws_iam_role_policy_attachment" "AWSGlueServiceRoleBatchProcessingS3" {
  role       = aws_iam_role.AWSGlueServiceRoleBatchProcessing.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "AWSGlueServiceRoleBatchProcessingRDSFA" {
  role       = aws_iam_role.AWSGlueServiceRoleBatchProcessing.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}
resource "aws_iam_role_policy_attachment" "AWSGlueServiceRoleBatchProcessingGCFA" {
  role       = aws_iam_role.AWSGlueServiceRoleBatchProcessing.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}
resource "aws_iam_role_policy_attachment" "AWSGlueServiceRoleBatchProcessingGCSMN" {
  role       = aws_iam_role.AWSGlueServiceRoleBatchProcessing.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleSageMakerNotebookFullAccess"
}
resource "aws_iam_role_policy_attachment" "AWSGlueServiceRoleBatchProcessingCW" {
  role       = aws_iam_role.AWSGlueServiceRoleBatchProcessing.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

data "aws_rds_cluster" "marvin-staging-use2-1" {
  cluster_identifier = "marvin-staging-use2-1"
}

data "aws_vpc" "marvin-staging-use2-data" {
  filter {
    name   = "tag:Name"
    values = ["marvin-staging-use2-data"]
  }
}
data "aws_subnet" "marvin-staging-use2-1" {
  vpc_id     = data.aws_vpc.marvin-staging-use2-data.id

  tags = {
    Name = "marvin-staging-use2-data-db-us-east-2a"
  }
}

provider "vault" {
  alias     = "apisec"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/apps/apisec"
}

data "vault_generic_secret" "pg_dump" {
  path     = "secret/staging/marvin/rds-marvin-staging-use2/aurora-db-credentials/pgmarvin-password"
  provider = vault.apisec
}


resource "aws_security_group" "marvin-staging-use2-data-glue" {
  name        = "marvin-staging-use2-data-glue"
  description = "Allow TCP inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.marvin-staging-use2-data.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_ipv4" {
  security_group_id            = aws_security_group.marvin-staging-use2-data-glue.id
  referenced_security_group_id = aws_security_group.marvin-staging-use2-data-glue.id
  from_port                    = 0
  ip_protocol                  = "tcp"
  to_port                      = 65535
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.marvin-staging-use2-data-glue.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_glue_connection" "rds-marvin-connection" {
  name = "rds-marvin-connection"

  connection_properties = {
    JDBC_CONNECTION_URL  = "jdbc:postgresql://${data.aws_rds_cluster.marvin-staging-use2-1.endpoint}:5432/marvin"
    PASSWORD            = data.vault_generic_secret.pg_dump.data["password"]
    USERNAME            = data.vault_generic_secret.pg_dump.data["user"]
  }
  physical_connection_requirements {
    availability_zone      = data.aws_subnet.marvin-staging-use2-1.availability_zone
    security_group_id_list = [aws_security_group.marvin-staging-use2-data-glue.id]
    subnet_id              = data.aws_subnet.marvin-staging-use2-1.id
  }
}
