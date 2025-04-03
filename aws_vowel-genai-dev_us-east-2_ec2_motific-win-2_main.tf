# This file was created by Outshift Platform Self-Service automation.

terraform {
  backend "s3" {
    # We separate the different levels of development into different buckets.
    # The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod.
    # The environment should match the CSBEnvironment below.
    bucket = "eticloud-tf-state-nonprod"
    # Note the path here. It should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    key = "terraform-state/vowel-genai-dev/us-east-2/ec2/motific-win-2.tfstate"
    # Do not change without talking to the SRE team. This is the region where the terraform backend bucket is located.
    region = "us-east-2"
  }
}

# Find instance types and cost here - https://instances.vantage.sh/?min_vcpus=4&region=us-east-2

module "ec2" {
  source = "git::https://github.com/cisco-eti/sre-tf-module-ec2-allinone.git?ref=latest"

  # EC2 Instance name
  name = "motific-win-2"

  # AWS provider region
  region = "us-east-2"

  # AWS account name
  aws_account_name = "vowel-genai-dev"

  # EC2 instance type
  instance_type = "m6a.xlarge"

  # AMI Type
  ami_type = "WINDOWS"

  # VPC Name
  vpc_name = "vpc-0477fed0518e53450"
  
  # User Management
  setup_s3_user_mgmt = "true"

  # Is the instance public
  is_public = "true"

  # Ignore AMI changes
  ignore_ami_changes = "true"

  # Tags
  cisco_mail_alias    = "hliu4@cisco.com"
  data_classification = "Cisco Restricted"
  data_taxonomy       = "Cisco Operations Data"
  environment         = "NonProd"
  resource_owner      = "Hong Liu"
}