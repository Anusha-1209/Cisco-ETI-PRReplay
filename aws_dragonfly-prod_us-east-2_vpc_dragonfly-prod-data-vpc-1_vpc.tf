module "vpc" {
  source                          = "git::https://github.com/cisco-eti/sre-tf-module-aws-vpc?ref=2.0.6"
  region                          = "us-east-2"
  vpc_cidr                        = "10.11.0.0/16"
  vpc_name                        = "dragonfly-data-prod-1-vpc"
  cluster_name                    = "dragonfly-data-eks" # Not used
  create_database_subnet_group    = true
  create_elasticache_subnet_group = false
}
