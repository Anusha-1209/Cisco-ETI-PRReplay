resource "aws_cloudwatch_metric_alarm" "lambda_invocations_alarm" {
  alarm_description = "Traffic spike alarm for lambda: ${local.lambda_function_name}-${var.env}"
  alarm_name = "${local.lambda_function_name}-${var.env}-lambda-invocation-alarm"
  metric_name = "Invocations"
  namespace = "AWS/Lambda"
  statistic = "Sum"
  period = "300"
  evaluation_periods = "2"
  threshold = var.lambda_invocation_threshold
  dimensions = {
    Name = "FunctionName"
    Value = aws_lambda_function.github_webhook_lambda.arn
  }
  comparison_operator = "GreaterThanThreshold"
}