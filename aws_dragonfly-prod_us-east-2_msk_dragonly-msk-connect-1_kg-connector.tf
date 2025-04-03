resource "aws_mskconnect_worker_configuration" "dragonfly_kg_worker_config" {
  name                    = "dragonfly-kg-worker"
  properties_file_content = <<EOT
# define names of config providers:
config.providers=secretsmanager
config.providers.secretsmanager.param.region=${data.aws_region.current.name}

key.converter=org.apache.kafka.connect.storage.StringConverter
value.converter=org.apache.kafka.connect.storage.StringConverter

# provide implementation classes for each provider:
config.providers.secretsmanager.class=com.amazonaws.kafka.config.providers.SecretsManagerConfigProvider
EOT
}

resource "aws_mskconnect_custom_plugin" "dragonfly_kg_connector" {
  name         = "${local.arangodb_connector_plugin_name}-plugin"
  content_type = "ZIP"
  location {
    s3 {
      bucket_arn = data.aws_s3_bucket.mskconnect_custom_plugin_bucket.arn
      file_key   = data.aws_s3_object.mskconnect_custom_plugin_jar.key
    }
  }
}

resource "aws_mskconnect_connector" "dragonfly_kg_connector" {
  name = "dragonfly-kg-connector"

  kafkaconnect_version = "2.7.1"

  capacity {
    autoscaling {
      mcu_count        = 1
      min_worker_count = 1
      max_worker_count = 10

      scale_in_policy {
        cpu_utilization_percentage = 20
      }

      scale_out_policy {
        cpu_utilization_percentage = 80
      }
    }
  }

  connector_configuration = {
    "connection.endpoints"           = "$${secretsmanager:dragonfly-msk-connect-kg:endpoint}"
    "connector.class"                = "com.arangodb.kafka.ArangoSinkConnector"
    "connection.password"            = "$${secretsmanager:dragonfly-msk-connect-kg:password}"
    "connection.user"                = "$${secretsmanager:dragonfly-msk-connect-kg:username}"
    "data.errors.log.enable"         = "true"
    "data.errors.tolerance"          = "all"
    "insert.overwriteMode"           = "UPDATE"
    "ssl.enabled"                    = "true"
    "ssl.hostname.verification"      = "true"
    "ssl.cert.value"                 = "$${secretsmanager:dragonfly-msk-connect-kg:ca-certificate}"
    "topics"                         = "$${secretsmanager:dragonfly-msk-connect-kg:topics}"
    "tasks.max"                      = "2"
    "value.converter.schemas.enable" = "false"
    "value.converter"                = "org.apache.kafka.connect.json.JsonConverter"
  }

  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = data.aws_msk_cluster.dragonfly_msk_1.bootstrap_brokers_sasl_iam

      vpc {
        security_groups = [
          aws_security_group.dragonfly_kg_1.id
        ]
        subnets = data.aws_subnets.msk_subnets.ids
      }
    }
  }

  kafka_cluster_client_authentication {
    authentication_type = "IAM"
  }

  kafka_cluster_encryption_in_transit {
    encryption_type = "TLS"
  }

  plugin {
    custom_plugin {
      arn      = aws_mskconnect_custom_plugin.dragonfly_kg_connector.arn
      revision = aws_mskconnect_custom_plugin.dragonfly_kg_connector.latest_revision
    }
  }

  service_execution_role_arn = aws_iam_role.msk_connect_kg_execution_role.arn

  worker_configuration {
    arn      = aws_mskconnect_worker_configuration.dragonfly_kg_worker_config.arn
    revision = aws_mskconnect_worker_configuration.dragonfly_kg_worker_config.latest_revision
  }

  log_delivery {
    worker_log_delivery {
      cloudwatch_logs {
        enabled = true
        log_group = aws_cloudwatch_log_group.dragonfly_kg_connector.name
      }
    }
  }
}
