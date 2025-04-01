locals {
  pipelines = {
    "dragonfly-osis-pipeline-1" = {

      topics = [
        "falco",
        "monitoring",
      ],
      min_units = 1,
      max_units = 4,
    },
    "dragonfly-osis-pipeline-2" = {
      topics = [
        "threat",
        "attack",
      ],
      min_units = 1,
      max_units = 4,
    },
  }
}

resource "awscc_osis_pipeline" "ingestion_pipeline" {
  for_each = local.pipelines

  pipeline_name = each.key
  pipeline_configuration_body = templatefile("./pipeline.yaml", {
    region          = data.aws_region.current.name
    sts_role_arn    = module.pipeline_role.iam_role_arn
    opensearch_host = data.aws_opensearch_domain.dragonfly_staging_1_os.endpoint

    msk_cluster_arn = data.aws_msk_cluster.dragonfly_msk_1.arn
    kafka_topics    = each.value.topics
  })

  min_units = each.value.min_units
  max_units = each.value.max_units

  log_publishing_options = {
    is_logging_enabled = true
    cloudwatch_log_destination = {
      log_group = aws_cloudwatch_log_group.dragonfly_staging_1_osis_logs[each.key].name
    }
  }
}

resource "aws_cloudwatch_log_group" "dragonfly_staging_1_osis_logs" {
  for_each = local.pipelines

  name = "/aws/vendedlogs/OpenSearchIngestion/${each.key}/audit-logs"
}
