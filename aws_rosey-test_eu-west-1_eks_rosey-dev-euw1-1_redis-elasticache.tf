data "aws_vpc" "vpc_dev" {
  filter {
    name   = "tag:Name"
    values = ["rosey-dev-euw1-1"]
  }
}

data "aws_subnets" "eks_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_dev.id]
  }
  tags = {
    Tier = "Private"
  }
}
module "elasticache_redis" {
  source                = "git::https://github.com/tmknom/terraform-aws-elasticache-redis.git?ref=tags/2.0.0"
  name                  = "rosey-dev-euw1-1"
  number_cache_clusters = "2"
  node_type             = "cache.t2.medium"

  engine_version             = "7.1"
  port                       = 6379
  maintenance_window         = "mon:10:40-mon:11:40"
  snapshot_window            = "09:10-10:10"
  snapshot_retention_limit   = 1
  automatic_failover_enabled = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  apply_immediately          = true

  subnet_ids         = data.aws_subnets.eks_subnets.ids
  vpc_id             = data.aws_vpc.vpc_dev.id
  source_cidr_blocks = ["10.0.0.0/16"]
  
  tags = {
    ApplicationName    = "eu-west-1-rosey-dev-euw1-1"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    EnvironmentName    = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
}