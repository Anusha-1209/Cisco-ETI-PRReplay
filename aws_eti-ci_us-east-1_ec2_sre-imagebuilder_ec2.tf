terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"                                              # We separate the different environments into different buckets. The buckets are eticloud-tf-state-nonprod, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key    = "terraform-state/ec2/us-east-1/etici-us-east-1-ec2-imagebuilder.tfstate" # #note the path here. It should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                                              # Do not change without talking to the SRE team.
  }
}

variable "vpc_name" {
  type = string
  default = "etici-vpc-us-east-1"
}
variable "cisco_cidrs" {
  type    = list(string)
  default = ["52.177.206.0/24", "216.151.141.0/24", "171.68.0.0/14", "66.163.32.0/20", "40.79.24.0/24", "13.68.72.0/24", "40.79.68.0/24", "64.103.0.0/16", "128.107.0.0/16", "20.186.6.0/24", "104.208.221.0/24", "52.254.19.0/24", "13.68.74.0/24", "52.254.51.0/24", "192.168.24.0/24", "171.38.209.0/24", "207.182.160.0/19", "64.102.0.0/16", "66.114.160.0/20", "20.186.37.0/24", "40.79.62.0/24", "52.251.62.0/24", "52.232.186.0/24", "161.44.0.0/16", "52.254.17.0/24", "104.209.145.0/24", "209.197.192.0/21", "40.84.4.0/24", "172.27.27.128/26", "52.179.217.112/28", "40.79.70.0/24", "52.254.77.0/24", "192.168.5.0/24", "3.21.137.64/26", "192.168.110.0/23", "173.36.0.0/14", "72.163.220.0/22", "172.18.136.0/21"]
}
variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-east-1"
}

data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/eticcprod/infra/ci/aws"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = var.AWS_INFRA_REGION
  max_retries = 3
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# AWS SG for sre-imagebuilder instance
module "sre-imagebuilder-sg00" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"
  name        = "sre-imagebuilder-sg00"
  description = "Security group 00 for imagebuilder"
  vpc_id      = data.aws_vpc.vpc.id
  computed_ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      cidr_blocks = join(",", var.cisco_cidrs)
      description = "Allow full communication with var.cisco_cidrs. Only applicable to publicly facing instances"
    }
  ]
  number_of_computed_ingress_with_cidr_blocks = 1
  ingress_with_self = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      self        = true
      description = "Allows full communication with itself"

    }
  ]
  computed_egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  number_of_computed_egress_with_cidr_blocks = 1
}

module "sre-imagebuilder-sg01" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"
  name        = "sre-imagebuilder-sg01"
  description = "Security group 01 for imagebuilder"
  vpc_id      = data.aws_vpc.vpc.id
  computed_ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = join(",", var.cisco_cidrs)
    }
  ]
  number_of_computed_ingress_with_cidr_blocks = 1
}

module "ec2-imagebuilder" {
  source = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-ec2.git?ref=1.1.4"
  ec2_name                        = "sre-imagebuilder"
  ec2_associate_public_ip_address = true
  ec2_instance_type               = "m5.metal"
  ec2_instance_count              = 1
  instance_os                     = "Ubuntu20"
  gpu_enabled                     = false
  ec2_vpc_security_group_ids = [
    module.sre-imagebuilder-sg00.this_security_group_id,
    module.sre-imagebuilder-sg01.this_security_group_id
  ]
  region                          = var.AWS_INFRA_REGION
  vpc_name                        = var.vpc_name
  key_name                        = "sre-imagebuilder"
  ec2_volume_size                 = 600
  hosted_zone_name                = "ci.eticloud.io"
  tag_application_name            = "sre-imagebuilder"
  tag_data_classification         = "Cisco Confidential"
  tag_environment                 = "Sandbox"
  tag_cisco_mail_alias            = "eti-sre@cisco.com"
  tag_data_taxonomy               = "Cisco Operations Data"
  tag_resource_owner              = "ETI SRE"
}
