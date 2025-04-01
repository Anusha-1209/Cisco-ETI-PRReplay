resource "aws_cloudwatch_log_group" "dragonfly_dev_1_os_logs" {
  name = "dragonfly-dev-1-os-logs"
}

resource "aws_cloudwatch_log_resource_policy" "opensearch_log_publishing_policy" {
  policy_document = data.aws_iam_policy_document.opensearch_log_publishing_policy.json
  policy_name     = "opensearch-log-publishing-policy"
}
