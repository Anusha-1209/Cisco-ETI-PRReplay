provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/motific-preview/terraform_admin" # Defines which account the resources will be created in. Can be eticloud, scratch, eticloud-scratch-c, eticloud-cil, eticloud-demo
}
provider "vault" {
  alias     = "vowel"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/apps/vowel"
}

data "vault_generic_secret" "public_key" {
  provider = vault.vowel
  path     = "secret/dev/vowel-dev-vms/motific-win-server" # Defines which account the resources will be created in. Can be eticloud, scratch, eticloud-scratch-c, eticloud-cil, eticloud-demo
}
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-sandbox"                               # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key    = "terraform-state/ec2/us-east-2/motific-preview-3.tfstate" # Note the path here. It should match the patten terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                               # Do not change
  }
}


provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}
data "aws_vpc" "vpc" {
  id = "vpc-0ce0196f05627d924" # Replace with your VPC ID
}
data "aws_security_group" "default" {
  id = "sg-0cc079537b7aa537e"
}
resource "aws_key_pair" "auth" {
  key_name   = "motific-win-server-key-pair"
  public_key = data.vault_generic_secret.public_key.data["public_key"]
}

resource "aws_instance" "motific-win-server" {
  ami                    = "ami-0e6aa5f69f06ffa91" # Replace with the latest Windows AMI in your region
  instance_type          = "t2.large"              # You can choose another instance type if required
  vpc_security_group_ids = [data.aws_security_group.default.id]
  subnet_id              = data.aws_vpc.vpc.id
  key_name               = aws_key_pair.auth.key_name
  tags = {
    data_classification = "Cisco Confidential"
    application_name    = "motific-win-server"
    cisco_mail_alias    = "eti-sre-admins@cisco.com"
    data_taxonomy       = "Cisco Operations Data"
    environment         = "Sandbox"
    resource_owner      = "ETI SRE"
  }
}

resource "aws_eip" "win_server_eip" {
  instance = aws_instance.motific-win-server.id
  vpc      = true
}