data "aws_caller_identity" "current" {}


resource "aws_iam_policy" "aws_msk_connect_msk_cluster_policy" {
  name = "MSKConnectMSKClusterPolicy-${aws_msk_cluster.marvin-prod-use2-1-msk.cluster_name}"
  policy = jsonencode({
    "Version"   = "2012-10-17"
    "Statement" = [
      {
        "Effect" : "Allow",
        "Action" : [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster"
        ],
        "Resource" : [
          aws_msk_cluster.marvin-prod-use2-1-msk.arn
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kafka-cluster:ReadData",
          "kafka-cluster:DescribeTopic"
        ],
        "Resource" : [
          "arn:aws:kafka:us-east-2:${data.aws_caller_identity.current.id}:topic/${aws_msk_cluster.marvin-prod-use2-1-msk.cluster_name}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kafka-cluster:WriteData",
          "kafka-cluster:DescribeTopic"
        ],
        "Resource" : [
          "arn:aws:kafka:us-east-2:${data.aws_caller_identity.current.id}:topic/${aws_msk_cluster.marvin-prod-use2-1-msk.cluster_name}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kafka-cluster:CreateTopic",
          "kafka-cluster:WriteData",
          "kafka-cluster:ReadData",
          "kafka-cluster:DescribeTopic"
        ],
        "Resource" : [
          "arn:aws:kafka:us-east-2:${data.aws_caller_identity.current.id}:topic/${aws_msk_cluster.marvin-prod-use2-1-msk.cluster_name}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kafka-cluster:AlterGroup",
          "kafka-cluster:DescribeGroup"
        ],
        "Resource" : [
          "arn:aws:kafka:us-east-2:${data.aws_caller_identity.current.id}:group/${aws_msk_cluster.marvin-prod-use2-1-msk.cluster_name}/*/__amazon_msk_connect_*",
          "arn:aws:kafka:us-east-2:${data.aws_caller_identity.current.id}:group/${aws_msk_cluster.marvin-prod-use2-1-msk.cluster_name}/*/connect-*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "aws_msk_connect_s3_bucket_policy" {
  name = "MSKConnectS3BucketPolicy-${aws_msk_cluster.marvin-prod-use2-1-msk.cluster_name}"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:*",
          "s3-object-lambda:*"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role" "aws_msk_connect_role" {
  name               = "MSKConnectRole-${aws_msk_cluster.marvin-prod-use2-1-msk.cluster_name}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "kafkaconnect.amazonaws.com"
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "StringEquals" : {
            "aws:SourceAccount" : data.aws_caller_identity.current.id
          },
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:kafkaconnect:us-east-2:${data.aws_caller_identity.current.id}:connector/*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws_msk_connect_s3_bucket_policy-attach" {
  role       = aws_iam_role.aws_msk_connect_role.name
  policy_arn = aws_iam_policy.aws_msk_connect_s3_bucket_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_msk_connect_msk_cluster_attach" {
  role       = aws_iam_role.aws_msk_connect_role.name
  policy_arn = aws_iam_policy.aws_msk_connect_msk_cluster_policy.arn
}

import {
  to = aws_s3_bucket.marvin-msk-connectors-bucket
  id = "marvin-prod-use2-1-msk-s3-connectors"
}

resource "aws_s3_bucket" "marvin-msk-connectors-bucket" {}

import {
  to = aws_s3_object.msk-connector-s3-object
  id = "/marvin-prod-use2-1-msk-s3-connectors/confluentinc-kafka-connect-s3-10.5.7.zip"
}

resource "aws_s3_object" "msk-connector-s3-object" {
  bucket = aws_s3_bucket.marvin-msk-connectors-bucket.id
  key    = "confluentinc-kafka-connect-s3-10.5.7.zip"
  source = "confluentinc-kafka-connect-s3-10.5.7.zip"
}

resource "aws_mskconnect_custom_plugin" "msk-connect-s3-connector-plugin" {
  depends_on = [aws_s3_object.msk-connector-s3-object]
  name         = "kafka-connect-s3"
  content_type = "ZIP"
  location {
    s3 {
      bucket_arn = aws_s3_bucket.marvin-msk-connectors-bucket.arn
      file_key   = aws_s3_object.msk-connector-s3-object.key
    }
  }
}

resource "aws_cloudwatch_log_group" "marvin-msk-connect-log_group" {
  name = "marvin-prod-use2-1-msk-connect-logs"
}

resource "aws_s3_bucket" "marvin-prod-use2-1-msk-sink" {
  bucket = "msk-connect-marvin-prod-use2-1"
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  bucket = aws_s3_bucket.marvin-prod-use2-1-msk-sink.id

  rule {
    id = "events_retention"

    expiration {
      days = 30
    }

    status = "Enabled"
  }
}

resource "aws_mskconnect_connector" "marvin-prod-use2-1-msk-connect" {
  name = "${aws_msk_cluster.marvin-prod-use2-1-msk.cluster_name}S3SinkConnect"

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
    "connector.class"="io.confluent.connect.s3.S3SinkConnector"
    "s3.region"="us-east-2"
    "partition.duration.ms"="60000"
    "flush.size"="1000"
    "schema.compatibility"="NONE"
    "tasks.max"="2"
    "timezone"="UTC"
    "topics"="events"
    "rotate.schedule.interval.ms"="30000"
    "offset.flush.interval.ms"="30000"
    "locale"="en-US"
    "format.class"="io.confluent.connect.s3.format.bytearray.ByteArrayFormat"
    "partitioner.class"="io.confluent.connect.storage.partitioner.TimeBasedPartitioner"
    "value.converter"="org.apache.kafka.connect.converters.ByteArrayConverter"
    "storage.class"="io.confluent.connect.s3.storage.S3Storage"
    "path.format"="'year'=YYYY/'month'=MM/'day'=dd/'hour'=HH"
    "s3.bucket.name"="msk-connect-marvin-prod-use2-1"
    "timestamp.extractor"="Record"
  }

  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = aws_msk_cluster.marvin-prod-use2-1-msk.bootstrap_brokers_tls

      vpc {
        security_groups = [aws_security_group.marvin-prod-use2-1-msk.id]
        subnets         = data.aws_subnets.msk_subnets.ids
      }
    }
  }

  kafka_cluster_client_authentication {
    authentication_type = "NONE"
  }

  kafka_cluster_encryption_in_transit {
    encryption_type = "TLS"
  }

  plugin {
    custom_plugin {
      arn      = aws_mskconnect_custom_plugin.msk-connect-s3-connector-plugin.arn
      revision = aws_mskconnect_custom_plugin.msk-connect-s3-connector-plugin.latest_revision
    }
  }

  service_execution_role_arn = aws_iam_role.aws_msk_connect_role.arn
  log_delivery {
    worker_log_delivery {
      cloudwatch_logs {
        enabled = true
        log_group = aws_cloudwatch_log_group.marvin-msk-connect-log_group.name
      }
    }
  }
}
