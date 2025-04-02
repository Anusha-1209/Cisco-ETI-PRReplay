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
  path     = "secret/infra/aws/outshift-common-dev/terraform_admin"
}

terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-nonprod" # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/outshift-common-dev/us-east-2/s3/marvin-pre-process-collect-events-dev-use2-1.tfstate"
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


resource "aws_sqs_queue" "marvin-pre-process-collect-events-dlq-dev-use2-1" {
  name = "marvin-pre-process-collect-events-dlq-dev-use2-1"
}

resource "aws_sqs_queue_redrive_allow_policy" "marvin-pre-process-collect-events-dlq-dev-use2-1" {
  queue_url = aws_sqs_queue.marvin-pre-process-collect-events-dlq-dev-use2-1.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.marvin-pre-process-collect-events-dev-use2-1.arn]
  })
}

resource "aws_sqs_queue" "marvin-pre-process-collect-events-dev-use2-1" {
  name = "marvin-pre-process-collect-events-dev-use2-1"
  fifo_queue = false
  visibility_timeout_seconds = 180
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.marvin-pre-process-collect-events-dlq-dev-use2-1.arn
    maxReceiveCount     = 4
  })
  tags = {
    CSBDataClassification = "Cisco Restricted"
    CSBEnvironment        = "NonProd"
    CSBApplicationName    = "Marvin"
    CSBResourceOwner      = "Outshift SRE"
    CSBCiscoMailAlias     = "eti-sre@cisco.com"
    CSBDataTaxonomy       = "Cisco Operations Data"
  }
}


resource "aws_lambda_event_source_mapping" "pii-reduction-marvin-use2-1-source-mapping" {
  event_source_arn = aws_sqs_queue.marvin-pre-process-collect-events-dev-use2-1.arn
  function_name    = "pii-reduction-marvin-dev-use2-1"
}

resource "aws_cloudwatch_metric_alarm" "marvin-pre-process-collect-events-dlq-alarm-dev-use2-1" {
  alarm_name          = "${aws_sqs_queue.marvin-pre-process-collect-events-dlq-dev-use2-1.name}-not-empty-alarm"
  alarm_description   = "Items are on the ${aws_sqs_queue.marvin-pre-process-collect-events-dlq-dev-use2-1.name} queue"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.marvin-pre-process-collect-events-dlq-sns-alarm-dev-use2-1.arn]
  tags = {
    CSBDataClassification = "Cisco Restricted"
    CSBEnvironment        = "NonProd"
    CSBApplicationName    = "Marvin"
    CSBResourceOwner      = "Outshift SRE"
    CSBCiscoMailAlias     = "eti-sre@cisco.com"
    CSBDataTaxonomy       = "Cisco Operations Data"
  }
  dimensions = {
    "QueueName" = aws_sqs_queue.marvin-pre-process-collect-events-dlq-dev-use2-1.name
  }
}
resource "aws_sns_topic" "marvin-pre-process-collect-events-dlq-sns-alarm-dev-use2-1" {
  name = "marvin-pre-process-collect-events-dlq-dev-use2-1"
}
resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.marvin-pre-process-collect-events-dlq-sns-alarm-dev-use2-1.arn
  protocol  = "https"
  endpoint  = "https://events.pagerduty.com/integration/43a07f5f49c8410bc01cad237cadd0c3/enqueue"
}

