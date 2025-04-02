# This provider allows access to the eticloud/eticcprod namespace in Keeper. Do not modify it without discussing with the SRE team.
provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

# Change `path = "secret/eticcprod/infra/<account_name>/aws" to specify the account in which the resources will be created.
# Must match the account in which the VPC was created.
data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/outshift-common-prod/terraform_admin"
}

terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-prod" # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/outshift-common-prod/us-east-2/s3/marvin-collect-events-prod-use2-1.tfstate"
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2" # DO NOT CHANGE.

  }
}

variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-east-2" #Set the region for the resources to be created.
}
# Infra AWS Provider
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.AWS_INFRA_REGION
  max_retries = 3
}

resource "aws_sqs_queue" "marvin-collect-events-dlq-prod-use2-1" {
  name = "marvin-collect-events-dlq-prod-use2-1"
}

resource "aws_sqs_queue_redrive_allow_policy" "marvin-collect-events-dlq-prod-use2-1" {
  queue_url = aws_sqs_queue.marvin-collect-events-dlq-prod-use2-1.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.marvin-prod-use2-1-collect-events.arn]
  })
}

resource "aws_sqs_queue" "marvin-prod-use2-1-collect-events" {
  name = "marvin-collect-events-prod-use2-1"
  fifo_queue = false
  tags = {
    CSBDataClassification = "Cisco Restricted"
    CSBEnvironment        = "Prod"
    CSBApplicationName    = "Marvin"
    CSBResourceOwner      = "Outshift SRE"
    CSBCiscoMailAlias     = "eti-sre@cisco.com"
    CSBDataTaxonomy       = "Cisco Operations Data"
  }
}

resource "aws_cloudwatch_metric_alarm" "marvin-collect-events-dlq-alarm-prod-use2-1-lp" {
  alarm_name          = "${aws_sqs_queue.marvin-collect-events-dlq-prod-use2-1.name}-not-empty-alarm"
  alarm_description   = "Items are on the ${aws_sqs_queue.marvin-collect-events-dlq-prod-use2-1.name} queue"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.marvin-collect-events-dlq-sns-alarm-prod-use2-1.arn]
  tags = {
    CSBDataClassification = "Cisco Restricted"
    CSBEnvironment        = "NonProd"
    CSBApplicationName    = "Marvin"
    CSBResourceOwner      = "Outshift SRE"
    CSBCiscoMailAlias     = "eti-sre@cisco.com"
    CSBDataTaxonomy       = "Cisco Operations Data"
  }
  dimensions = {
    "QueueName" = aws_sqs_queue.marvin-collect-events-dlq-prod-use2-1.name
  }
}

resource "aws_cloudwatch_metric_alarm" "marvin-collect-events-dlq-alarm-lp-prod-use2-1" {
  alarm_name          = "${aws_sqs_queue.marvin-collect-events-dlq-prod-use2-1.name}-not-empty-alarm"
  alarm_description   = "Items are on the ${aws_sqs_queue.marvin-collect-events-dlq-prod-use2-1.name} queue"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.marvin-collect-events-dlq-sns-alarm-lp-prod-use2-1.arn]
  tags = {
    CSBDataClassification = "Cisco Restricted"
    CSBEnvironment        = "NonProd"
    CSBApplicationName    = "Marvin"
    CSBResourceOwner      = "Outshift SRE"
    CSBCiscoMailAlias     = "eti-sre@cisco.com"
    CSBDataTaxonomy       = "Cisco Operations Data"
  }
  dimensions = {
    "QueueName" = aws_sqs_queue.marvin-collect-events-dlq-prod-use2-1.name
  }
}

resource "aws_cloudwatch_metric_alarm" "marvin-collect-events-dlq-alarm-hp-prod-use2-1-hp" {
  alarm_name          = "${aws_sqs_queue.marvin-collect-events-dlq-prod-use2-1.name}-not-empty-alarm"
  alarm_description   = "Items are on the ${aws_sqs_queue.marvin-collect-events-dlq-prod-use2-1.name} queue"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Average"
  threshold           = 100
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.marvin-collect-events-dlq-sns-alarm-hp-prod-use2-1.arn]
  tags = {
    CSBDataClassification = "Cisco Restricted"
    CSBEnvironment        = "NonProd"
    CSBApplicationName    = "Marvin"
    CSBResourceOwner      = "Outshift SRE"
    CSBCiscoMailAlias     = "eti-sre@cisco.com"
    CSBDataTaxonomy       = "Cisco Operations Data"
  }
  dimensions = {
    "QueueName" = aws_sqs_queue.marvin-collect-events-dlq-prod-use2-1.name
  }
}

resource "aws_sns_topic" "marvin-collect-events-dlq-sns-alarm-lp-prod-use2-1" {
  name = "marvin-collect-events-dlq-lp-prod-use2-1"
}
resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.marvin-collect-events-dlq-sns-alarm-lp-prod-use2-1.arn
  protocol  = "https"
  endpoint  = "https://events.pagerduty.com/integration/43a07f5f49c8410bc01cad237cadd0c3/enqueue"
}

resource "aws_sns_topic" "marvin-collect-events-dlq-sns-alarm-hp-prod-use2-1" {
  name = "marvin-collect-events-dlq-hp-prod-use2-1"
}
resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.marvin-collect-events-dlq-sns-alarm-hp-prod-use2-1.arn
  protocol  = "https"
  endpoint  = "https://events.pagerduty.com/integration/43a07f5f49c8410bc01cad237cadd0c3/enqueue"
}
