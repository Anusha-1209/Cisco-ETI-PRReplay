module "eti-cisco-prod-cloudfront" {
  providers = {
    aws = aws.us-east-2
  }
  source                        = "terraform-aws-modules/cloudfront/aws"
  version                       = "2.6.0"
  aliases                       = ["eti.cisco.com", ]
  comment                       = "eti.cisco.com"
  enabled                       = true
  is_ipv6_enabled               = true
  price_class                   = "PriceClass_All"
  retain_on_delete              = false
  wait_for_deployment           = false
  create_origin_access_identity = false
  logging_config = {
    bucket = module.eti-cisco-prod_log_bucket.s3_bucket_bucket_domain_name
    prefix = "cloudfront"
  }
  web_acl_id = "arn:aws:wafv2:us-east-1:626007623524:global/webacl/eti-website-threatstop/4d198ae8-807a-4f8a-9520-91fb661b1462"
  default_cache_behavior = {
    path_pattern           = "*"
    target_origin_id       = "group_ab"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    query_string           = true
    use_forwarded_values   = false
    compress               = true
    min_ttl                = 0
    max_ttl                = 0
    default_ttl            = 0
  }
  ordered_cache_behavior = [
    {
      path_pattern             = "api/*"
      target_origin_id         = "origin_a"
      viewer_protocol_policy   = "redirect-to-https"
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "DELETE", "PATCH", "POST", "PUT"]
      cached_methods           = ["GET", "HEAD"]
      compress                 = false
      query_string             = true
      use_forwarded_values     = false
      compress                 = true
      min_ttl                  = 0
      max_ttl                  = 0
      default_ttl              = 0
      cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      origin_request_policy_id = "1d8a1aa2-e223-4cee-ab1a-298c100fda10"
    },
    {
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      compress               = true
      default_ttl            = 86400
      max_ttl                = 31535979
      path_pattern           = "_next/*"
      smooth_streaming       = false
      target_origin_id       = "group_ab"
      trusted_key_groups     = []
      trusted_signers        = []
      viewer_protocol_policy = "redirect-to-https"
      forwarded_value = {
        headers                 = []
        query_string            = true
        query_string_cache_keys = []
        cookies = {
          forward           = "none"
          whitelisted_names = []
        }
      }

    }
  ]
  origin = {
    a = {
      connection_attempts = 3
      connection_timeout  = 10
      domain_name         = "eti-blue-a.prod.eticloud.io"
      origin_id           = "origin_a"
      custom_origin_config = {
        http_port                = 80
        https_port               = 443
        origin_keepalive_timeout = 5
        origin_protocol_policy   = "https-only"
        origin_read_timeout      = 30
        origin_ssl_protocols = [
          "TLSv1.2"
        ]
      }
      origin_shield = {
        enabled              = true
        origin_shield_region = "us-east-2"
      }
    }
    b = {
      connection_attempts = 3
      connection_timeout  = 10
      domain_name         = "eti-blue-b.prod.eticloud.io"
      origin_id           = "origin_b"
      custom_origin_config = {
        http_port                = 80
        https_port               = 443
        origin_keepalive_timeout = 5
        origin_protocol_policy   = "https-only"
        origin_read_timeout      = 30
        origin_ssl_protocols = [
          "TLSv1.2"
        ]
        origin_shield = {
          enabled              = true
          origin_shield_region = "us-west-2"
        }
      }
    }
  }
  origin_group = {
    group_ab = {
      failover_status_codes = [
        403,
        404,
        500,
        502,
        503,
        504,
      ]
      primary_member_origin_id   = "origin_a"
      secondary_member_origin_id = "origin_b"
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
    acm_certificate_arn      = "arn:aws:acm:us-east-1:626007623524:certificate/51320ce4-3dd2-4678-9b86-7453305fb712"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
#############
# S3 buckets
#############

data "aws_canonical_user_id" "current" {}
module "eti-cisco-prod_log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.6.0"
  bucket  = "eti-cisco-prod-logs"
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