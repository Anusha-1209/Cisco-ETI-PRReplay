data "tls_certificate" "gh_actions" {
  url = local.gh_actions_oidc_provider_url
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_role" "cloudformation_execution_role" {
  name = "dragonfly-cloudformation-execution-role"
}
