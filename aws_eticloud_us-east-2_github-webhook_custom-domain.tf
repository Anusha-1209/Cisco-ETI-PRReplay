resource "aws_apigatewayv2_domain_name" "api_gateway_domain_name" {
  domain_name = "github-webhook.eticloud.io"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.acm.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# Example DNS record using Route53.
# Route53 is not specifically required; any DNS host can be used.
resource "aws_route53_record" "route53_api_gateway" {
  name    = aws_apigatewayv2_domain_name.api_gateway_domain_name.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.route53_zone.id

  alias {
    evaluate_target_health = true
    name                   = aws_apigatewayv2_domain_name.api_gateway_domain_name.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_gateway_domain_name.domain_name_configuration[0].hosted_zone_id
  }
  depends_on = [
    data.aws_route53_zone.route53_zone
  ]
}
