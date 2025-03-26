terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc/us-east-2/cisco-quantum-3.tfstate"
    region = "us-east-2"
  }
}

locals {
  name             = "cisco-quantum-3"
  region           = "us-west-2"
  aws_account_name = "cisco-research"
}

# Find instance types and cost here - https://instances.vantage.sh/?min_vcpus=4&region=us-east-2

module "ec2" {
  source             = "git::https://github.com/cisco-eti/sre-tf-module-ec2-allinone.git?ref=2.0.3"
  name               = local.name             # VPC name
  region             = local.region           # AWS provider region
  aws_account_name   = local.aws_account_name # AWS account name
  instance_type      = "g5.2xlarge"           # EC2 instance type
  availability_zone  = "us-west-2c"
  is_public          = true                  # Is the instance public
  ignore_ami_changes = true                  # Ignore AMI changes
  ami_type           = "UBUNTU"              # Windows AMI OS Flavor
  vpc_name           = "cisco-quantum-vpc-1" # VPC Name
}