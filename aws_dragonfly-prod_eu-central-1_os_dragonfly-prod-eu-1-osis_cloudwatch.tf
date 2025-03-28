resource "aws_cloudwatch_log_group" "dragonfly_prod_eu_1_osis_logs" {
  name = "/aws/vendedlogs/OpenSearchIngestion/${var.pipeline_name}/audit-logs"
}
