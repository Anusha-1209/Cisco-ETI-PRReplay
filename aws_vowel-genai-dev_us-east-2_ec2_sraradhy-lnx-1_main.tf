# This file was created by Outshift Platform Self-Service automation.

terraform {
  backend "s3" {
    # We separate the different levels of development into different buckets. 
    # The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. 
    # The environment should match the CSBEnvironment below.
    bucket = "eticloud-tf-state-nonprod"                                                           

    # Note the path here. It should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    key    = "terraform-state/vowel-genai-dev/us-east-2/ec2/sraradhy-lnx-1.tfstate"

    # Do not change without talking to the SRE team.
    region = "us-east-2"
  }
}

# Find instance types and cost here - https://instances.vantage.sh/?min_vcpus=4&region=us-east-2

module "ec2" {
  source = "git::https://github.com/cisco-eti/sre-tf-module-ec2-allinone.git?ref=latest"

  # EC2 Instance name
  name = "sraradhy-lnx-1"

  # AWS provider region
  region = "us-east-2"

  # AWS account name
  aws_account_name = "vowel-genai-dev"

  # EC2 instance type
  instance_type = "t3.nano"

  # AMI Type
  ami_type = "CISCO_HARDENED_AL2"

  # VPC Name
  vpc_name = "motific-dev-use2-vms"

  # Is the instance public
  is_public = "true"

  # Ignore AMI changes
  ignore_ami_changes = "true"

  # Tags
  cisco_mail_alias    = "<no value>"
  data_classification = "Cisco Restricted"
  data_taxonomy       = "Cisco Operations Data"
  environment         = "NonProd"
  resource_owner      = "SRE"
}
