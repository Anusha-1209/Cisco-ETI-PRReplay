# This file was created by Outshift Platform Self-Service automation.

terraform {
  backend "s3" {
    # We separate the different levels of development into different buckets.
    # The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod.
    # The environment should match the CSBEnvironment below.
    bucket = "eticloud-tf-state-sandbox"
    # Note the path here. It should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    key = "terraform-state/cisco-research/us-east-2/ec2/cisco-research-16.tfstate"
    # Do not change without talking to the SRE team. This is the region where the terraform backend bucket is located.
    region = "us-east-2"
  }
}

# Find instance types and cost here - https://instances.vantage.sh/?min_vcpus=4&region=us-east-2

module "ec2" {
  source = "git::https://github.com/cisco-eti/sre-tf-module-ec2-allinone.git?ref=latest"

  # EC2 Instance name
  name = "cisco-research-16"

  # AWS provider region
  region = "us-east-2"

  # AWS account name
  aws_account_name = "cisco-research"

  # EC2 instance type
  instance_type = "m6a.xlarge"

  # AMI Type
  ami_type = "UBUNTU"

  # VPC Name
  vpc_name = "cisco-research-vpc"

  # Is the instance public
  is_public = "false"

  # Ignore AMI changes
  ignore_ami_changes = "true"

  setup_s3_user_mgmt = true

  # Tags
  cisco_mail_alias    = "eti-sre-admins@cisco.com"
  data_classification = "Cisco Confidential"
  data_taxonomy       = "Cisco Operations Data"
  environment         = "Sandbox"
  resource_owner      = "ETI SRE"
}
