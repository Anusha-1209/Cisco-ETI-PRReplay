# Describes the statefile and table in the eticloud aws account. Each Atlantis project should have it's own statefile (key)
terraform {
  backend "s3" {
    bucket        = "eticloud-tf-state-sandbox" # We separate the different levels of development into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key           = "terraform-state/vpc/eu-central-1/quantum-research-vpc.tfstate" # #note the path here. It should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    region        = "us-east-2" # Do not change without talking to the SRE team.
  }
}

# There is a default vault provider. This provider specifies to use the alternate namespace for AWS credentials.
provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
  alias = "eticcprod"
}

# Specify the AWS account to use in <aws_account>.
data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path = "secret/eticcprod/infra/cisco-research/aws" 
}
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "eu-central-1" # Defines the default region where resources are created if not otherwise specified.
  max_retries = 3
  default_tags {
    # The module variables.tf have descriptions of these tags and their options.
    tags = {
      ApplicationName    = "ETI Platform VPC"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Restricted"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "Sandbox"
      ResourceOwner      = "ETI SRE"
    }
  }
}



module "vpc" {
  source                          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-vpc?ref=2.0.2"
  region                          = "eu-central-1" # The region where the resources will be created. Should match the AWS provider region.
  vpc_name                        = "quantum-research" # The vpc_name will get `-vpc` added to it.
  vpc_cidr                        = "10.24.0.0/16" # Check active cloud resources for conflicts.
  cluster_name                    = "quantum-research-eks" # The name of an EKS cluster to be installed.
}