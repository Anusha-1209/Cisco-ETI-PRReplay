module "vpc" {
  source                          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-vpc?ref=1.3.2" # The reference specifies the version of the 
  region                          = var.AWS_INFRA_REGION
  vpc_cidr                        = var.vpc_cidr
  cluster_name                    = var.cluster_name
  create_database_subnet_group    = var.create_database_subnet_group
  create_elasticache_subnet_group = var.create_elasticache_subnet_group
}
