data "aws_vpc" "db_vpc" {
  filter {
    name   = "tag:ApplicationName"
    values = ["motf-preview-use2-data-vpc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.db_vpc.id]
  }

  tags = {
    Tier = "Private"
  }
}

data "aws_security_group" "vpc_default" {
  vpc_id = data.aws_vpc.db_vpc.id
  name = "default"
}

data "aws_vpc" "eks_vpc" {
  filter {
    name   = "tag:Name"
    values = ["motf-preview-use2-1"]
  }
}

data "aws_security_group" "eks-sg" {
  vpc_id = data.aws_vpc.eks_vpc.id

  filter {
    name = "tag:Name"
    values = ["eks-cluster-sg-motf-preview-use2-1*"]
  }
}


output "vpc_db_security_group" {
  value = data.aws_security_group.vpc_default.id
}

### SASL/SCRAM secrets for cluster auth

resource "aws_secretsmanager_secret" "msk_secret" {
  name       = "AmazonMSK_msk-motific-preview"
  kms_key_id = aws_kms_key.msk_custom_key.key_id
  recovery_window_in_days = 0

  description = "SASL/SCRAM secret for msk-motific-preview"
}

resource "aws_kms_key" "msk_custom_key" {
  description = "Custom Key for MSK Cluster Scram Secret Association"
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "msk_credentials" {
  provider = vault.eticloud
  path = "secret/infra/msk/motf-preview-use2-1"
}

resource "aws_secretsmanager_secret_version" "msk_secret" {
  secret_id     = aws_secretsmanager_secret.msk_secret.id
  secret_string = data.vault_generic_secret.msk_credentials.data_json
}

data "aws_iam_policy_document" "msk_secret" {
  statement {
    sid    = "AWSKafkaResourcePolicy"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["kafka.amazonaws.com"]
    }

    actions   = ["secretsmanager:getSecretValue"]
    resources = [aws_secretsmanager_secret.msk_secret.arn]
  }
}

resource "aws_secretsmanager_secret_policy" "msk_secret" {
  secret_arn = aws_secretsmanager_secret.msk_secret.arn
  policy     = data.aws_iam_policy_document.msk_secret.json
}

# Allow inbound from db vpc CIDR to SASL/SCRAM port 9096 for bastion tunnels
resource "aws_security_group_rule" "kafka_ingress_eks_motf-preview-use2-1" {
  type              = "ingress"
  from_port         = 9096
  to_port           = 9096
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.db_vpc.cidr_block]
  security_group_id = data.aws_security_group.vpc_default.id
}

module "msk" {
  source               = "cloudposse/msk-apache-kafka-cluster/aws"
  version              = "2.3.0"
  name                 = "motf-preview-use2-1"
  vpc_id               = data.aws_vpc.db_vpc.id
  subnet_ids           = data.aws_subnets.private.ids
  kafka_version        = "3.3.2"
  broker_instance_type = "kafka.m5.large"
  properties = {
    "auto.create.topics.enable"      = true
    "default.replication.factor"     = 3
    "min.insync.replicas"            = 2
    "num.io.threads"                 = 8
    "num.network.threads"            = 5
    "num.partitions"                 = 10
    "num.replica.fetchers"           = 2
    "replica.lag.time.max.ms"        = 30000
    "socket.receive.buffer.bytes"    = 102400
    "socket.request.max.bytes"       = 104857600
    "socket.send.buffer.bytes"       = 102400
    "unclean.leader.election.enable" = true
    "zookeeper.session.timeout.ms"   = 18000
  }

  # security groups to put on the cluster itself
  associated_security_group_ids = [data.aws_security_group.vpc_default.id]
  # security groups to give access to the cluster
  allowed_security_group_ids = [data.aws_security_group.eks-sg.id]
  client_sasl_scram_enabled  = true
  client_sasl_scram_secret_association_arns = [aws_secretsmanager_secret.msk_secret.arn]
  jmx_exporter_enabled = true
  node_exporter_enabled = true
  enhanced_monitoring = "PER_TOPIC_PER_PARTITION"
}
