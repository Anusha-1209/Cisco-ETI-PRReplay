resource "aws_msk_configuration" "configuration" {
  kafka_versions = [var.kafka_version]
  name           = "dragonfly-msk-prod-eu1"

  server_properties = <<PROPERTIES
auto.create.topics.enable = true
PROPERTIES
}

resource "aws_msk_scram_secret_association" "msk_auth_credentials" {
  cluster_arn = aws_msk_cluster.dragonfly_msk_eu1.arn
  secret_arn_list = [
    for s in aws_secretsmanager_secret.msk_auth_credentials : s.arn
  ]

  depends_on = [aws_secretsmanager_secret_version.msk_auth_credentials_1]
}

resource "aws_msk_cluster" "dragonfly_msk_eu1" {
  cluster_name           = "dragonfly-msk-prod-eu1"
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

    // Turn on multi-vpc connectivity
    connectivity_info {
      vpc_connectivity {
        client_authentication {
          sasl {
            scram = false
            iam   = true
          }
        }
      }
    }

    security_groups = [aws_security_group.dragonfly_msk_eu1.id]
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
      scram = true
      iam   = true
    }
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

// Save brokers in vault
resource "vault_generic_secret" "msk_brokers_sasl_scram" {
  path = "secret/prod/msk/dragonfly-msk-eu1/brokers"

  data_json = jsonencode({
    brokers = aws_msk_cluster.dragonfly_msk_eu1.bootstrap_brokers_sasl_scram
  })

  provider = vault.dragonfly
}

resource "aws_msk_cluster_policy" "opensearch_ingestion_policy" {
  cluster_arn = aws_msk_cluster.dragonfly_msk_eu1.arn

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "osis.amazonaws.com"
        },
        "Action" : [
          "kafka:CreateVpcConnection",
          "kafka:DescribeCluster",
          "kafka:DescribeClusterV2"
        ],
        "Resource" : aws_msk_cluster.dragonfly_msk_eu1.arn
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "osis-pipelines.amazonaws.com"
        },
        "Action" : [
          "kafka:CreateVpcConnection",
          "kafka:GetBootstrapBrokers",
          "kafka:DescribeCluster",
          "kafka:DescribeClusterV2"
        ],
        "Resource" : aws_msk_cluster.dragonfly_msk_eu1.arn
    }]
  })
}
