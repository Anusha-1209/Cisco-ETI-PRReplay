resource "aws_msk_configuration" "configuration" {
  kafka_versions = [var.kafka_version]
  name           = "marvin-prod-use2-1-msk"

  server_properties = <<PROPERTIES
auto.create.topics.enable = true
PROPERTIES
}

resource "aws_msk_scram_secret_association" "msk_auth_credentials" {
  cluster_arn = aws_msk_cluster.marvin-prod-use2-1-msk.arn
  secret_arn_list = [
    for s in aws_secretsmanager_secret.msk_auth_credentials : s.arn
  ]

  depends_on = [aws_secretsmanager_secret_version.msk_auth_credentials_1]
}

resource "aws_msk_cluster" "marvin-prod-use2-1-msk" {
  cluster_name           = "marvin-prod-use2-1-msk"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes

  // Broker configuration
  broker_node_group_info {
    instance_type = var.instance_type

    client_subnets = data.aws_subnets.msk_subnets.ids

    storage_info {
      ebs_storage_info {
        volume_size = 1000
      }
    }

    security_groups = [aws_security_group.marvin-prod-use2-1-msk.id]
  }

  // Encryption
  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.encryption_key.arn

    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  // Authentication
  client_authentication {

    sasl {
      // TODO change to IAM, so that we can use the IAM role
      // and we don't have to setup ACLs
      scram = true
    }
    unauthenticated = true
  }

  // Cluster config
  configuration_info {
    arn      = aws_msk_configuration.configuration.arn
    revision = aws_msk_configuration.configuration.latest_revision
  }

  // Monitoring && logging
  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  enhanced_monitoring = "PER_TOPIC_PER_PARTITION"

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.broker_logs.name
      }
    }
  }
}
