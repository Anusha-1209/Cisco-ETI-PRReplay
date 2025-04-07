# API Gateway
resource "aws_apigatewayv2_api" "github_webhook_api" {
  name          = local.api_gateway_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.github_webhook_api.id

  name        = "prod"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.github_webhook_log_group.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "github_webhook_api_integration" {
  api_id = aws_apigatewayv2_api.github_webhook_api.id

  integration_uri         = aws_lambda_function.github_webhook_lambda.invoke_arn
  integration_type        = "AWS_PROXY"
  integration_method      = "POST"
  payload_format_version  = "2.0"
}

resource "aws_apigatewayv2_route" "github_webhook_api_route" {
  api_id = aws_apigatewayv2_api.github_webhook_api.id

  route_key = "POST /github"
  target    = "integrations/${aws_apigatewayv2_integration.github_webhook_api_integration.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.github_webhook_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.github_webhook_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  api_id      = aws_apigatewayv2_api.github_webhook_api.id
  domain_name = aws_apigatewayv2_domain_name.api_gateway_domain_name.id
  stage       = aws_apigatewayv2_stage.stage.id
}
