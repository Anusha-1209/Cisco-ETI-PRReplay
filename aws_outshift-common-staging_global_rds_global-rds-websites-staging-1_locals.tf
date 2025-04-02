locals {
  aws_account_name   = "outshift-common-staging"
  data_primary_vpc   = "common-staging-use2-vpc-data"
  data_secondary_vpc = "common-staging-usw2-vpc-data"
  eks_primary_vpc    = "comn-staging-use2-1"
  eks_secondary_vpc  = "comn-staging-usw2-1"
  rds_name           = "global-rds-websites-staging-1"
}