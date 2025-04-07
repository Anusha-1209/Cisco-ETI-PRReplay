# Infra AWS Provider
provider "aws" {
  alias       = "us-east-2"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3

  default_tags {
    tags = local.default_tags
  }
}

module "cloudwatch_metric_stream_us-east-2" {
  source              = "../../../../modules/cloudwatch-metric-stream"
  splunk_ingest_url   = local.splunk_ingest_url
  splunk_access_token = data.vault_generic_secret.generic_user_splunk_credential.data["outshift.signalfx.com_session_token"]
  providers = {
    aws = aws.us-east-2
  }
}
