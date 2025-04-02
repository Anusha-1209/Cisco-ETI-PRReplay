# resource "aws_iam_service_linked_role" "dragonfly_linked_role" {
#   aws_service_name = "opensearchservice.amazonaws.com"
# }

data "aws_iam_policy_document" "dragonfly_admin_access_policy" {
  statement {
    sid = "admin"

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["es:*"]

    resources = ["arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"]
  }
}

data "aws_iam_policy_document" "opensearch_log_publishing_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]

    resources = ["arn:aws:logs:*"]

    principals {
      identifiers = ["opensearchservice.amazonaws.com"]
      type        = "Service"
    }
  }
}
