resource "aws_cloudwatch_metric_alarm" "CNDR_Opensearch_Cluster_Index_Writes_Blocked" {
  alarm_name                = "CNDR_Opensearch_Cluster_Index_Writes_Blocked"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "ClusterIndexWritesBlocked"
  namespace                 = "AWS/OPENSEARCH"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 1
  alarm_description         = "This metric monitors the of blocked index writes in the OpenSearch cluster."
  insufficient_data_actions = []
}