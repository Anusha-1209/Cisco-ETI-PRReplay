terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/outshift-common-prod/us-east-2/documentdb/genie-prod-use2-documentdb-1.tfstate"
    region = "us-east-2"
  }
}

module "genie_prod_documentdb_cluster" {
  source                = "git::https://github.com/cisco-eti/sre-tf-module-aws-documentdb?ref=1.0.1"
  account_name          = "outshift-common-prod"
  application_name_tag  = "outshift_common_services"
  component_tag         = "genie"
  resource_owner_tag    = "genie"
  environment           = "prod"
  engine_version        = "5.0.0"
  master_username       = "genie"
  instances             = 3
  instance_class        = "db.r6g.xlarge"
  vpc_data_name         = "common-prod-use2-vpc-data"
  vpc_eks_name          = "comn-prod-use2-1"
  venture_namespace     = "genie"
  secret_path           = "secret/prod/documentDB"
}