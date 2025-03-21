
module "eks" {
  source                    = "../../../../../modules/eks"
  name                      = local.name
  cidr                      = local.vpc_cidr

  # SRE Variables
  application_name          = local.name
  region                    = local.region
  aws_infra_credential_path = local.aws_infra_credential_path
}