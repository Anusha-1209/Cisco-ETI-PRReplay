terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-nonprod" # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/outshift-common-dev/us-east-2/documentdb/pi-dev-use2-documentdb-1.tfstate" # UPDATE ME.
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2" # DO NOT CHANGE.
  }
}

module "documentdb_cluster" {
  source            = "git::https://github.com/cisco-eti/sre-tf-module-aws-documentdb?ref=develop"
  account_name      = "outshift-common-dev"
  application_name  = "pi-dev-use2-documentdb-1"
  environment       = "dev"
  engine_version    = "5.0.0"
  master_username   = "pi"
  instances         = 2
  instance_class    = "db.r6g.large"
  vpc_data_name     = "venture-data-vpc-name"
  vpc_eks_name      = "venture-eks-vpc-name"
  venture_namespace = "ppu"
}
