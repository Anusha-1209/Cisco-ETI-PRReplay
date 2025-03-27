locals {
  # Get distinct list of domains and SANs
  distinct_domain_names = distinct(
    [for s in concat([local.cdn_domain_name], [local.cdn_domain_name]) : replace(s, "*.", "")]
  )

  # Copy domain_validation_options for the distinct domain names
  validation_domains = [for k, v in aws_acm_certificate.this.domain_validation_options : tomap(v) if contains(local.distinct_domain_names, replace(v.domain_name, "*.", ""))]
}

data "aws_route53_zone" "domain" {
  provider = aws.route53
  name = "dev.phoenix-ui.app"
}
resource "aws_acm_certificate" "this" {
  provider = aws.us-east-1
  domain_name               = local.cdn_domain_name
  subject_alternative_names = [local.cdn_domain_name]
  validation_method         = "DNS"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
}


resource "aws_route53_record" "validation" {
  count = length(local.distinct_domain_names)
  provider = aws.route53
  zone_id =   data.aws_route53_zone.domain.zone_id
  name    = element(local.validation_domains, count.index)["resource_record_name"]
  type    = element(local.validation_domains, count.index)["resource_record_type"]
  ttl     = 60

  records = [
    element(local.validation_domains, count.index)["resource_record_value"]
  ]

  allow_overwrite = true

  depends_on = [aws_acm_certificate.this]
}