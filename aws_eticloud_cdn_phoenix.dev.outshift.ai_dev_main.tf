module "phoenix-ui-dev-cloudfront" {
  providers = {
    aws = aws.us-east-1
  }
  source                        = "terraform-aws-modules/cloudfront/aws"
  version                       = "3.4.0"
  aliases                       = [local.cdn_domain_name]
  comment                       = local.cdn_domain_name
  enabled                       = true
  http_version                  = "http2and3"
  is_ipv6_enabled               = true
  price_class                   = "PriceClass_All"
  retain_on_delete              = false
  wait_for_deployment           = false
  default_root_object           = "index.html"
  # When you enable additional metrics for a distribution, CloudFront sends up to 8 metrics to CloudWatch in the US East (N. Virginia) Region.
  # This rate is charged only once per month, per metric (up to 8 metrics per distribution).
  create_monitoring_subscription = false
  create_origin_access_identity  = false

  custom_error_response = {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }
  default_cache_behavior = {
    path_pattern               = "*"
    target_origin_id           = "outshift-phoenix-ui"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = false
    query_string               = true
    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress                   = true
    min_ttl                    = 0
    max_ttl                    = 0
    default_ttl                = 0
    compress                   = false
    use_forwarded_values       = false
  }

  origin = {
    outshift-phoenix-ui = {
        connection_attempts      = 3
        connection_timeout       = 10
        domain_name              = "outshift-phoenix-ui.s3.us-east-2.amazonaws.com"
        origin_id                = "outshift-phoenix-ui"

        origin_shield = {
            enabled              = true
            origin_shield_region = "us-east-2"
          }
      }
  }
  viewer_certificate = {
    acm_certificate_arn      =  resource.aws_acm_certificate.this.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  depends_on = [
    resource.aws_acm_certificate.this
  ]
}