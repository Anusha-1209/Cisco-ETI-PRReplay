
resource "aws_glue_catalog_table" "aws_glue_catalog_marvin_sandbox_1_table" {
  name          = "events_dev_sandbox_1_use2_1"
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
    location      = "s3://msk-connect-marvin-dev-use2-1/topics/events-sandbox-1/"
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

resource "aws_glue_connection" "rds-marvin-sandbox-1-connection" {
  name = "rds-marvin-sandbox-1-connection"
  connection_type = "CUSTOM"

  connection_properties = {
    CONNECTION_TYPE      = "Jdbc"
    JDBC_CONNECTION_URL  = "jdbc:postgres://${data.aws_rds_cluster.marvin-dev-use2-1.endpoint}/marvin-sandbox-1"
    PASSWORD            = data.vault_generic_secret.pg_dump.data["user"]
    USERNAME            = data.vault_generic_secret.pg_dump.data["password"]
  }
  physical_connection_requirements {
    availability_zone      = data.aws_subnet.marvin-dev-use2-1.availability_zone
    security_group_id_list = data.aws_rds_cluster.marvin-dev-use2-1.vpc_security_group_ids
    subnet_id              = data.aws_subnet.marvin-dev-use2-1.id
  }
}
