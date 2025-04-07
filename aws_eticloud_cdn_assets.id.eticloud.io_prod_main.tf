module "eti-identity-static-assets-cloudfront" {
  source                        = "terraform-aws-modules/cloudfront/aws"
  version                       = "2.6.0"
  aliases                       = ["assets.id.eticloud.io", ]
  comment                       = "assets.id.eticloud.io static assets"
  enabled                       = true
  is_ipv6_enabled               = true
  price_class                   = "PriceClass_All"
  retain_on_delete              = false
  wait_for_deployment           = false
  create_origin_access_identity = false
  logging_config = {
    bucket = module.prod_log_bucket.s3_bucket_bucket_domain_name
    prefix = "cloudfront"
  }
  default_cache_behavior = {
    path_pattern           = "*"
    target_origin_id       = "eti-identity-assets-s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = false
    query_string           = true
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = true
    min_ttl                = 0
    max_ttl                = 0
    default_ttl            = 0
    compress               = false
    use_forwarded_values   = false
  }

  origin = {
    a = {
      connection_attempts = 3
      connection_timeout  = 10
      domain_name         = "cisco-eti-identity-static-assets.s3.us-east-2.amazonaws.com"
      origin_id           = "eti-identity-assets-s3"

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
    DataClassification = var.prod_tag_data_classification
    DataTaxonomy       = var.prod_tag_data_taxonomy
    CiscoMailAlias     = var.prod_tag_cisco_mail_alias
    ApplicationName    = var.prod_tag_application_name
    Environment        = var.prod_tag_environment
    ResourceOwner      = var.prod_tag_resource_owner
  }
  default_root_object = var.prod_default_root_object
  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:626007623524:certificate/3affef23-21cd-437e-a3eb-58a541441a30"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

#############
# S3 buckets
#############

data "aws_canonical_user_id" "current" {}
module "prod_log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.6.0"
  bucket  = "cisco-eti-identity-static-assets-cdn-access-logs"
  acl     = null
  grant = [{
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
    id          = data.aws_canonical_user_id.current.id
    }, {
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
    id          = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
    # Ref. https://github.com/terraform-providers/terraform-provider-aws/issues/12512
    # Ref. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
  }]
  force_destroy = true
  tags = {
    DataClassification = var.prod_tag_data_classification
    DataTaxonomy       = var.prod_tag_data_taxonomy
    CiscoMailAlias     = var.prod_tag_cisco_mail_alias
    ApplicationName    = var.prod_tag_application_name
    Environment        = var.prod_tag_environment
    ResourceOwner      = var.prod_tag_resource_owner
  }
}
