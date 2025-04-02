resource "aws_mskconnect_worker_configuration" "dragonfly-kg-worker-config" {
  name                    = "dragonfly-kg-worker"
  properties_file_content = <<EOT
key.converter=org.apache.kafka.connect.storage.StringConverter
value.converter=org.apache.kafka.connect.storage.StringConverter

# define names of config providers:
config.providers=secretsmanager

# provide implementation classes for each provider:
config.providers.secretsmanager.class=com.amazonaws.kafka.config.providers.SecretsManagerConfigProvider
config.providers.secretsmanager.param.region=${data.aws_region.current.name}
EOT
}

resource "aws_mskconnect_custom_plugin" "dragonfly-kg-connector" {
  name         = "${local.arangodb_connector_plugin_name}-plugin"
  content_type = "JAR"
  location {
    s3 {
      bucket_arn = data.aws_s3_bucket.mskconnect_custom_plugin_bucket.arn
      file_key   = data.aws_s3_object.arangodb_connector_plugin_jar.key
    }
  }
}

resource "aws_mskconnect_connector" "dragonfly-kg-connector" {
  name = "dragonfly-kg-connector"

  kafkaconnect_version = "2.7.1"

  capacity {
    autoscaling {
      mcu_count        = 1
      min_worker_count = 1
      max_worker_count = 2

      scale_in_policy {
        cpu_utilization_percentage = 20
      }

      scale_out_policy {
        cpu_utilization_percentage = 80
      }
    }
  }

  connector_configuration = {
    "connector.class"                = "com.arangodb.kafka.ArangoSinkConnector"
    "ssl.enabled"                    = "true"
    "tasks.max"                      = "2"
    "data.errors.tolerance"          = "all"
    "connection.endpoints"           = "arangodb.eks-dragonfly-dev-1.dev.eticloud.io:8529"
    "insert.overwriteMode"           = "UPDATE"
    "data.errors.log.enable"         = "true"
    "connection.user"                = "root"
    "value.converter.schemas.enable" = "false"
    "ssl.hostname.verification"      = "true"
    "value.converter"                = "org.apache.kafka.connect.json.JsonConverter"
    "connection.password"            = "$${ecretsmanager:dragonfly-msk-connect-kg:password}"
    "connection.ca.crt"              = "$${secretsmanager:dragonfly-msk-connect-kg:ca-certificate}"
  }

  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = data.aws_msk_cluster.dragonfly_msk_1.bootstrap_brokers_sasl_iam

      vpc {
        security_groups = [
          aws_security_group.dragonfly_msk_1.id
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
      arn      = aws_mskconnect_custom_plugin.dragonfly-kg-connector.arn
      revision = aws_mskconnect_custom_plugin.dragonfly-kg-connector.latest_revision
    }
  }

  service_execution_role_arn = aws_iam_role.msk_connect_execution_role.arn

  worker_configuration {
    arn      = aws_mskconnect_worker_configuration.dragonfly-kg-worker-config.arn
    revision = aws_mskconnect_worker_configuration.dragonfly-kg-worker-config.latest_revision
  }
}
