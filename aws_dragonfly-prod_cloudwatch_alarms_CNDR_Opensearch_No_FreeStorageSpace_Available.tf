resource "aws_cloudwatch_metric_alarm" "CNDR_Opensearch_No_FreeStorageSpace_Available" {
  alarm_name                = "CNDR_Opensearch_No_FreeStorageSpace_Available"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "FreeStorageSpace"
  namespace                 = "AWS/OPENSEARCH"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 50000
  alarm_actions             = [aws_sns_topic.dragonfly-urgent-pagerduty.arn]
  ok_actions                = [aws_sns_topic.dragonfly-urgent-pagerduty.arn]
  alarm_description         = "This metric monitors the amount of free storage space in the OpenSearch cluster."
  insufficient_data_actions = []
}