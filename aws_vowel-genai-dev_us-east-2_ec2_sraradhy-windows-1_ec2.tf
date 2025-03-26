terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc/us-east-2/motific-vm-1.tfstate"
    region = "us-east-2"
  }
}

locals {
  name             = "sraradhy-windows-1"
  region           = "us-east-2"
  aws_account_name = "vowel-genai-dev"
}

# Find instance types and cost here - https://instances.vantage.sh/?min_vcpus=4&region=us-east-2

module "ec2" {
  source             = "git::https://github.com/cisco-eti/sre-tf-module-ec2-allinone.git?ref=latest"
  name               = local.name             # VPC name
  region             = local.region           # AWS provider region
  aws_account_name   = local.aws_account_name # AWS account name
  instance_type      = "m6a.xlarge"           # EC2 instance type
  is_public          = true                   # Is the instance public
  ignore_ami_changes = true                   # Ignore AMI changes
  ami_type           = "WINDOWS"              # Windows AMI OS Flavor
  vpc_name           = "motific-dev-use2-vms" # VPC Name
}