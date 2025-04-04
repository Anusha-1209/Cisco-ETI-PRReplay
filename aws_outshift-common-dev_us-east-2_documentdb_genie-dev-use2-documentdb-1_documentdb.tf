terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/outshift-common-dev/us-east-2/documentdb/genie-dev-use2-documentdb-1.tfstate"
    region = "us-east-2"
  }
}

module "genie_dev_documentdb_cluster" {
  source                = "git::https://github.com/cisco-eti/sre-tf-module-aws-documentdb?ref=1.0.1"
  account_name          = "outshift-common-dev" # id 471112537430
  application_name_tag  = "outshift_common_services"
  component_tag         = "genie"
  resource_owner_tag    = "genie"
  environment           = "dev"
  engine_version        = "5.0.0"
  master_username       = "genie"
  instances             = 3
  instance_class        = "db.r6g.xlarge"
  vpc_data_name         = "common-dev-use2-vpc-data"
  vpc_eks_name          = "comn-dev-use2-1"
  venture_namespace     = "genie"
  secret_path           = "secret/dev"
}