resource "awscc_osis_pipeline" "ingestion_pipeline" {
  pipeline_name = var.pipeline_name
  pipeline_configuration_body = templatefile("./pipeline.yaml", {
    region          = data.aws_region.current.name
    sts_role_arn    = module.pipeline_role.iam_role_arn
    opensearch_host = data.aws_opensearch_domain.dragonfly_prod_eu_1_os.endpoint

    msk_cluster_arn = data.aws_msk_cluster.dragonfly_msk_eu1.arn
    kafka_topics = [
      "falco",
      "monitoring",
    ]
  })

  min_units = 1
  max_units = 4

  log_publishing_options = {
    is_logging_enabled = true
    cloudwatch_log_destination = {
      log_group = aws_cloudwatch_log_group.dragonfly_prod_eu_1_osis_logs.name
    }
  }
}
