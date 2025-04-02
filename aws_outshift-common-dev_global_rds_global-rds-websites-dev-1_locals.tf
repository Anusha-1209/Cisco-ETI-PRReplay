locals {
  aws_account_name   = "outshift-common-dev"
  data_primary_vpc   = "common-dev-use2-vpc-data"
  data_secondary_vpc = "common-dev-usw2-vpc-data"
  eks_primary_vpc    = "comn-dev-use2-1"
  eks_secondary_vpc  = "comn-dev-usw2-1"
  rds_name           = "global-rds-websites-dev-1"
}