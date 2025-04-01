############### STEP 1: AWS Provider Configuration ###################
# provider "vault" {
#   alias     = "eticloud"
#   namespace = "eticloud"
# }

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/apps/dragonfly"
  alias     = "venture"
}

provider "vault" {
  alias     = "eticcprod"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_lightspin_staging_infra_credentials" {
  provider = vault.eticcprod
  path     = "secret/eticcprod/infra/lightspin-staging/aws"
}

data "vault_generic_secret" "aws_eticloud_infra_credentials" {
    provider = vault.eticcprod
    path     = "secret/eticcprod/infra/prod/aws"
}

# Infra AWS Providers
provider "aws" {
  alias       = "lightspin-staging"
  access_key  = data.vault_generic_secret.aws_lightspin_staging_infra_credentials.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_lightspin_staging_infra_credentials.data["AWS_SECRET_ACCESS_KEY"]
  region      = "eu-west-1"
  max_retries = 3
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_eticloud_infra_credentials.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_eticloud_infra_credentials.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}

terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-nonprod"
    key            = "backend/keeper/ci-secret-engines/aws-lightspin-staging.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}

############################## IAM User ######################################
# that Vault's secrets engine will use to provision your dynamic credentials #
##############################################################################
resource "aws_iam_user" "vault_secrets_engine_lightspin_staging_user" {
  provider   = aws.lightspin-staging
  name       = "vault-secrets-engine-lightspin-staging-user"
}

resource "aws_iam_access_key" "vault_secrets_engine_user_credentials" {
  provider  = aws.lightspin-staging
  user      = aws_iam_user.vault_secrets_engine_lightspin_staging_user.name
}

############################## IAM Policy ######################################
resource "aws_iam_user_policy" "name" {
  provider  = aws.lightspin-staging
  name      = "vault-secrets-engine-policy"
  user      = aws_iam_user.vault_secrets_engine_lightspin_staging_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = "${aws_iam_role.sqs_lightspin_staging_role.arn}"
      },
    ]
  })
}

############################## SQS IAM Role ##################################
resource "aws_iam_role" "sqs_lightspin_staging_role" {
  provider  = aws.lightspin-staging
  name      = "sqs-lightspin-staging-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${aws_iam_user.vault_secrets_engine_lightspin_staging_user.arn}"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_policy" "sqs_lightspin_staging_policy" {
  provider    = aws.lightspin-staging
  name        = "sqs-lightspin-staging-policy"
  description = "SQS lightspin staging policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sqs:SendMessage",
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage"
            ],
            "Resource": "arn:aws:sqs:eu-west-1:523054802825:lightspin-staging-1.fifo"
        }
    ]
}
  EOF
}

resource "aws_iam_policy_attachment" "sqs_policy_attachment" {
  provider   = aws.lightspin-staging
  name       = "sqs-policy-attachment"
  roles      = [aws_iam_role.sqs_lightspin_staging_role.name]
  policy_arn = aws_iam_policy.sqs_lightspin_staging_policy.arn
}