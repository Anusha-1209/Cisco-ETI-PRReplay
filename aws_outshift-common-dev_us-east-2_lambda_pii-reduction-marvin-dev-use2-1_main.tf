# This provider allows access to the eticloud/eticcprod namespace in Keeper. Do not modify it without discussing with the SRE team.
provider "vault" {
alias     = "eticloud"
address   = "https://keeper.cisco.com"
namespace = "eticloud"
}

# Change `path = "secret/eticcprod/infra/<account_name>/aws" to specify the account in which the resources will be created.
# Must match the account in which the VPC was created.
data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/outshift-common-dev/terraform_admin"
}

terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-nonprod" # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/outshift-common-dev/us-east-2/lambda/pii-reduction-marvin-dev-use2-1.tfstate"
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2" # DO NOT CHANGE.

  }
}

variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-east-2" #Set the region for the resources to be created.
}
# Infra AWS Provider
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.AWS_INFRA_REGION
  max_retries = 3
}

data "aws_caller_identity" "current_outshift_common" {}

locals {
  cluster_name = "marvin-dev-use2-1" # The name of the associated EKS cluster. Must be updated
  account_id = data.aws_caller_identity.current_outshift_common.account_id
}

module "lambda_function_container_image" {
  source = "terraform-aws-modules/lambda/aws"
  function_name = "pii-reduction-marvin-dev-use2-1"
  description   = "Marvin Pii reduction"
  create_package = false
  timeout = 180
  memory_size = 3008
  image_uri    = "471112537430.dkr.ecr.us-east-2.amazonaws.com/marvin/presidio-lambda:latest"
  package_type = "Image"
  attach_policy_statements = true
  policy_statements =
    {
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Action": [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ],
        "Resource": "arn:aws:sqs:*:${local.account_id}:*"
      }]
    }
}
