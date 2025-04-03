module "cdr-ui-dev-cloudfront" {
  source                        = "terraform-aws-modules/cloudfront/aws"
  version                       = "3.4.0"
  aliases                       = ["cdr-ui.dev.eticloud.io"]
  comment                       = "cdr-ui.dev.eticloud.io"
  enabled                       = true
  http_version                  = "http2and3"
  is_ipv6_enabled               = true
  price_class                   = "PriceClass_All"
  retain_on_delete              = false
  wait_for_deployment           = false
  # When you enable additional metrics for a distribution, CloudFront sends up to 8 metrics to CloudWatch in the US East (N. Virginia) Region.
  # This rate is charged only once per month, per metric (up to 8 metrics per distribution).
  create_monitoring_subscription = false
  create_origin_access_identity  = false

  logging_config = {
    bucket = module.dev_log_bucket.s3_bucket_bucket_domain_name
    prefix = "cloudfront"
  }

  default_cache_behavior = {
    path_pattern               = "*"
    target_origin_id           = "dragonfly-dev-cdr-ui"
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
    a = {
      connection_attempts = 3
      connection_timeout  = 10
      domain_name         = local.bucket_domain_name
      origin_id           = "dragonfly-dev-cdr-ui"

      custom_origin_config = {
        http_port                = 80
        https_port               = 443
        origin_keepalive_timeout = 5
        origin_protocol_policy   = "https-only"
        origin_read_timeout      = 30
        origin_ssl_protocols = [
          "TLSv1.2",
        ]
      }
    }
  }

  tags = {
    ApplicationName    = "dragonfly"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
  
  viewer_certificate = {
    acm_certificate_arn      = module.acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  depends_on = [
    module.acm
  ]
}

#############
# S3 buckets
#############

data "aws_canonical_user_id" "current" {}
data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}

module "dev_log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.1"
  bucket  = "cdr-ui-dev-cdn-access-logs"
  acl     = null
  grant = [{
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
    id          = data.aws_canonical_user_id.current.id
    }, {
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
    id          = data.aws_cloudfront_log_delivery_canonical_user_id.cloudfront.id
    # Ref. https://github.com/terraform-providers/terraform-provider-aws/issues/12512
    # Ref. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
  }]
  force_destroy = true
  tags = {
    ApplicationName    = "dragonfly"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
}