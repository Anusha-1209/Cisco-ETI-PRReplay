module "research-cisco-prod-cloudfront" {
  source                        = "terraform-aws-modules/cloudfront/aws"
  version                       = "2.6.0"
  aliases                       = ["research.cisco.com", ]
  comment                       = "research.cisco.com"
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
    target_origin_id       = "origin_a"
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
  ordered_cache_behavior = [
    {
      allowed_methods = [
        "GET",
        "HEAD",
        "OPTIONS",
        "DELETE",
        "PATCH",
        "POST",
        "PUT"
      ]
      cached_methods = [
        "GET",
        "HEAD",
      ]
      cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      compress                 = true
      default_ttl              = 0
      max_ttl                  = 0
      min_ttl                  = 0
      path_pattern             = "api/*"
      smooth_streaming         = false
      target_origin_id         = "origin_a"
      trusted_key_groups       = []
      trusted_signers          = []
      viewer_protocol_policy   = "redirect-to-https"
      use_forwarded_values     = false
      origin_request_policy_id = "1d8a1aa2-e223-4cee-ab1a-298c100fda10"
      query_string             = true
    },
    {
      allowed_methods = [
        "GET",
        "HEAD",
        "OPTIONS"
      ]
      cached_methods = [
        "GET",
        "HEAD",
      ]
      path_pattern           = "_next/*"
      compress               = true
      default_ttl            = 0
      max_ttl                = 0
      min_ttl                = 0
      cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      origin_request_policy_id = "1d8a1aa2-e223-4cee-ab1a-298c100fda10"
      target_origin_id       = "group_ab"
      viewer_protocol_policy = "redirect-to-https"
      query_string           = true
      use_forwarded_values   = false

    }
  ]



  origin = {
    a = {
      connection_attempts = 3
      connection_timeout  = 10
      domain_name         = "prod-blue-a.research.eticloud.io"
      origin_id           = "origin_a"

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

      origin_shield = {
        enabled              = true
        origin_shield_region = "us-east-2"
      }
    }

    b = {
      connection_attempts = 3
      connection_timeout  = 10
      domain_name         = "prod-blue-b.research.eticloud.io"
      origin_id           = "origin_b"

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

      origin_shield = {
        enabled              = true
        origin_shield_region = "us-west-2"
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
    acm_certificate_arn      = "arn:aws:acm:us-east-1:626007623524:certificate/ca495869-e824-4b15-b374-a29ae6c5b2fd"
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
  bucket  = "research-cisco-prod-logs"
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
