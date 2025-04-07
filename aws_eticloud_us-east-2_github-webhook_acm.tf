resource "aws_acm_certificate" "acm" {
  domain_name       = "github-webhook.eticloud.io"
  validation_method = "DNS"

  tags = {
    DataClassification = var.DataClassification
    Environment        = var.Environment
    ApplicationName    = var.ApplicationName
    ResourceOwner      = var.ResourceOwner
    CiscoMailAlias     = var.CiscoMailAlias
    DataTaxonomy       = var.DataTaxonomy
  }
}

resource "aws_route53_record" "route53_record" {
  for_each = {
    for dvo in aws_acm_certificate.acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.route53_zone.zone_id
}

resource "aws_acm_certificate_validation" "acm_validation" {
  certificate_arn         = aws_acm_certificate.acm.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_record : record.fqdn]
}

