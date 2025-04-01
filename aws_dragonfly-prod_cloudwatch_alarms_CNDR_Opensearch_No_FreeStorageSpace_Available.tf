resource "aws_cloudwatch_metric_alarm" "CNDR_Opensearch_No_FreeStorageSpace_Available" {
  alarm_name                = "CNDR_Opensearch_No_FreeStorageSpace_Available"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 2
  threshold                 = 50000
  alarm_actions             = [aws_sns_topic.dragonfly-urgent-pagerduty.arn]
  ok_actions                = [aws_sns_topic.dragonfly-urgent-pagerduty.arn]
  alarm_description         = "This metric monitors the amount of free storage space in the OpenSearch cluster."
  insufficient_data_actions = []

  metric_query {
    id = "m1"
    return_data = true

    metric {
      metric_name = "FreeStorageSpace"
      namespace   = "AWS/ES"
      period      = 300
      stat        = "Maximum"
      dimensions = {
        DomainName = "os-dragonfly-prod-1"
        ClientId = "651416187950"
      }
    }
  }
}