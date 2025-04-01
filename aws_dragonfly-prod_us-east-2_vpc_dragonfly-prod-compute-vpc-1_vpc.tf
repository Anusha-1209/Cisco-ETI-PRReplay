module "vpc" {
  source                          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-vpc?ref=2.0.4"
  region                          = "us-east-2"
  vpc_cidr                        = "10.10.0.0/16"
  vpc_name                        = "dragonfly-compute-prod-1"
  cluster_name                    = "dragonfly-prod-1"
  create_database_subnet_group    = false
  create_elasticache_subnet_group = false
}
