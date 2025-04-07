locals {
  aws_account_name   = "outshift-common-prod"
  data_primary_vpc   = "common-prod-use2-vpc-data"
  data_secondary_vpc = "common-prod-usw2-vpc-data"
  eks_primary_vpc    = "comn-prod-use2-1"
  eks_secondary_vpc  = "comn-prod-usw2-1"
  rds_name           = "global-rds-genie-prod-1"
}