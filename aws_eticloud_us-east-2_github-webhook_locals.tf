locals  {
  lambda_function_name = "${var.appname_prefix}-lambda"
  github_webhook_secret = "${var.appname_prefix}-secret"
  sqs_name = "${var.appname_prefix}-sqs"
  api_gateway_name = "${var.appname_prefix}-api"
  s3_bucket_name = "${var.appname_prefix}-api"
}
