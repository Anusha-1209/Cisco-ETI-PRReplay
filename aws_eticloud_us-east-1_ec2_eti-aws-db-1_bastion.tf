data "vault_generic_secret" "aws_infra_credential" {
  path="secret/eticcprod/infra/prod/aws"
}

terraform {
  backend "s3" {
    bucket        = "eticloud-tf-state-nonprod" # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key           = "terraform-state/bastion/us-east-1/eti-aws-db-1-bastion.tfstate" # #note the path here. It should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    region        = "us-east-2" # Do not change without talking to the SRE team.
  }
}
  variable "AWS_INFRA_REGION" {
  description     = "AWS Region"
  default         = "us-east-1"
}

provider "aws" {
  access_key      = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key      = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region          = var.AWS_INFRA_REGION
  max_retries     = 3
}

module "bastion" {
  source                       = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-bastion?ref=v1.1.5"
  create_dns_record            = false
  region                       = var.AWS_INFRA_REGION
  vpc_subnet                   = "172.30.0.0/16"
  auto_scaling_group_subnets   = ["subnet-0c3f4225fcdd11a17","subnet-062c8cfda91095faa"]
  allow_ssh_commands           = "True"
  vault_path                   = "eti-aws-db-1-vpc"
  bastion_iam_policy_name      = "eti-aws-db-1-vpc"
  bastion_launch_template_name = "eti-aws-db-1-vpc"
  hosted_zone_id               = "Z0137785FSHHHEYXY6C5"
  vpc_id                       = "vpc-00c7460633e07501b"
  bastion_host_key_pair        = "eti-aws-db-1-vpc"
  tags = {
    Team               = "eti-sre"
    GithubOrg          = "eti"
    Name               = "eti-aws-db-1-bastion"
    Cluster            = "eti-aws-db-1"
    DataClassification = "Cisco Confidential"
    Environment        = "NonProd"
    ApplicationName    = "eti-aws-db"
    ResourceOwner      = "eti-sre"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataTaxonomy       = "Cisco Operations Data"
  }
}
