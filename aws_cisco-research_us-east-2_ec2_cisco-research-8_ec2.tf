provider "vault" {
  alias     = "eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path     = "secret/eticcprod/infra/cisco-research/aws" # Defines which account the resources will be created in. Can be eticloud, scratch, eticloud-scratch-c, eticloud-cil, eticloud-demo
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-sandbox"                              # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key    = "terraform-state/ec2/us-east-2/cisco-research-8.tfstate" # Note the path here. It should match the patten terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                              # Do not change
  }
}


provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}

module "ec2" {
  source                          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-ec2?ref=1.1.8"
  ec2_name                        = "cisco-research-8" # The name of the instance(s) to be created. Will be appended with a number.
  ec2_associate_public_ip_address = false              # Whether the instance(s) will have a public IP address. If true, the instances will be created in public subnets and additional security groups will be required.
  ec2_instance_count              = 1                  # The number of instances to create.
  ec2_instance_type               = "p3.8xlarge"
  gpu_enabled                     = true             # Defaults to false. If set to true, the instance os will always be Amazon Linux 2 (the only option with GPU drivers)
  vpc_name                        = "cisco-research" # The name of the VPC where the instance will be created.
  instance_os                     = "AmazonLinux2"   # Should usually be Ubuntu20 or AmazonLinux2; will always Amazon Linux 2 if gpu_enabled set to true.
  ec2_volume_size                 = "1000"           # The size, in GB, of the root volume. Default is 100GB
  region                          = "us-east-2"
  hosted_zone_name                = "cisco-research.eticloud.io" # An SRE team member should look up this name.
  tag_data_classification         = "Cisco Confidential"
  tag_application_name            = "cisco-research-8"
  tag_cisco_mail_alias            = "eti-sre-admins@cisco.com"
  tag_data_taxonomy               = "Cisco Operations Data"
  tag_environment                 = "Sandbox"
  tag_resource_owner              = "ETI SRE"
}
