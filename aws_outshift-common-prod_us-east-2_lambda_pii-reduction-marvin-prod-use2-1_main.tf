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
  path     = "secret/infra/aws/outshift-common-prod/terraform_admin"
}

terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-prod" # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/outshift-common-prod/us-east-2/lambda/pii-reduction-marvin-prod-use2-1.tfstate"
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
  cluster_name = "marvin-prod-use2-1" # The name of the associated EKS cluster. Must be updated
  account_id = data.aws_caller_identity.current_outshift_common.account_id
}

module "lambda_function_container_image" {
  source = "terraform-aws-modules/lambda/aws"
  function_name = "pii-reduction-marvin-prod-use2-1"
  description   = "Marvin Pii reduction"
  create_package = false
  timeout = 180
  memory_size = 3008
  image_uri    = "626007623524.dkr.ecr.us-east-2.amazonaws.com/marvin/images/pii-service/server:2024-07-15-4e2acc8"
  package_type = "Image"
  attach_policy_statements = true
  policy_statements = {
    sqs = {
      effect    = "Allow",
      actions   = [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:getQueueattributes"
      ]
      resources = ["arn:aws:sqs:*:${local.account_id}:*"]
    }
    ecr = {
      effect: "Allow",
      actions: [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      resources: ["arn:aws:ecr:us-east-2:626007623524:repository/marvin/images/pii-service/server"]
    }
  }
  docker_additional_options = [
    "-e", "SQS_URL='https://sqs.us-east-2.amazonaws.com/058264538874/marvin-collect-events-prod-use2-1'"
  ]
}

