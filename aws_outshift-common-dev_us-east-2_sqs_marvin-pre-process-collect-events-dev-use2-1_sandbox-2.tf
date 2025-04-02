resource "aws_sqs_queue" "marvin-pre-process-collect-events-dev-sandbox-2-use2-1" {
  name = "marvin-pre-process-collect-events-dev-sandbox-2-use2-1"
  fifo_queue = false
  visibility_timeout_seconds = 180
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
  function_name    = "pii-reduction-marvin-dev-sandbox-2-use2-1"
}
