module "cloudtrail" {
  count                 = 1
  source                = "github.com/falcosecurity/falco-aws-terraform.git//modules/infrastructure/cloudtrail"
  name                  = local.name
  is_organizational     = false
  is_multi_region_trail = true
  cloudtrail_kms_enable = true
}

module "sqs_sns_subscription" {
  source        = "github.com/falcosecurity/falco-aws-terraform.git//modules/infrastructure/sqs-sns-subscription"
  name          = local.name
  sns_topic_arn = module.cloudtrail[0].sns_topic_arn
}

module "resource_group" {
  source = "github.com/falcosecurity/falco-aws-terraform.git//modules/infrastructure/resource-group"
  name   = local.name
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = "cisco-eti-eticloud-dragonfly-trail-626007623524"

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_iam_role" "dragonfly_falco_data_collector" {
  name = "dragonfly-falco"
  assume_role_policy = data.aws_iam_policy_document.dragonfly_falco_data_collector_assume_role.json
}

resource "aws_iam_policy" "dragonfly_falco_data_collector_ro" {
  name        = "dragonfly-falco-cloudtrail-ro"
  description = "Dragonfly Falco policy to consume Cloudtrails' trails"

  policy = data.aws_iam_policy_document.dragonfly_falco_data_collector.json
}

resource "aws_iam_role_policy_attachment" "dragonfly_falco_data_collector_ro" {
  role       = aws_iam_role.dragonfly_falco_data_collector.name
  policy_arn = aws_iam_policy.dragonfly_falco_data_collector_ro.arn
}
