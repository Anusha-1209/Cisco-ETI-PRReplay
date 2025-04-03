locals {
  aws_account_name   = "outshift-common-prod"
  data_primary_vpc   = "platform-prod-use2-vpc-data"
  data_secondary_vpc = "platform-prod-usw2-vpc-data"
  eks_primary_vpc    = "plat-prod-use2-1"
  eks_secondary_vpc  = "plat-prod-usw2-1"
  rds_name           = "global-rds-platform-prod-1"
}