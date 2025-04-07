provider "vault" {
    alias = "eticcprod"
    address = "https://keeper.cisco.com"
    namespace = "eticloud/eticcprod"
}

# Atlantis has credentials to the eticloud AWS account. It uses those credentials to store and retrieve state information.
# `Path=` specifies the path to credentials in Keeper. The assumed namespace is eticloud/eticcprod.
# This data call is required for all accounts. The two current options are "scratch" (as below) and "prod".
data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path="secret/eticcprod/infra/prod/aws"
}
terraform {
  backend "s3" {
    bucket        = "eticloud-tf-state-prod" # Do not change without talking to the SRE team.
    key           = "terraform-state/codeartifact/us-east-2/prod-codeartifact.tfstate" # The statefile name should be descriptive and must be unique.
    region        = "us-east-2" # Do not change without talking to the SRE team.
  }
}

variable "AWS_INFRA_REGION" {
  description     = "AWS Region"
  default         = "us-east-2"
}


# By setting the AWS provider credentials via the data source above, we control in which account and region the resources get created.
provider "aws" {
  access_key      = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key      = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region          = var.AWS_INFRA_REGION
  max_retries     = 3
}




resource "aws_kms_key" "outshift_codeartifact" {
  description = "outshift codeartifact"
}

resource "aws_codeartifact_domain" "outshift_codeartifact" {
  domain         = "outshift"
  encryption_key = aws_kms_key.outshift_codeartifact.arn
}


# SCS venture
resource "aws_codeartifact_repository" "outshift_codeartifact" {
  repository = "cnapp-scs-private"
  domain     = aws_codeartifact_domain.outshift_codeartifact.domain
  upstream {
    repository_name = aws_codeartifact_repository.npm_public.repository
  }

  upstream {
    repository_name = aws_codeartifact_repository.pypi_public.repository
  }
}

resource "aws_codeartifact_repository" "npm_public" {
  repository = "cnapp-scs-npm-upstream"
  domain     = aws_codeartifact_domain.outshift_codeartifact.domain

  external_connections {
    external_connection_name = "public:npmjs"
  }
}

resource "aws_codeartifact_repository" "pypi_public" {
  repository = "cnapp-scs-pypi-upstream"
  domain     = aws_codeartifact_domain.outshift_codeartifact.domain

  external_connections {
    external_connection_name = "public:pypi"
  }
}


# Genie venture
resource "aws_codeartifact_repository" "genie_genie_ai_private" {
  repository = "genie-genie-ai-private"
  domain     = aws_codeartifact_domain.outshift_codeartifact.domain
    
  upstream {
    repository_name = aws_codeartifact_repository.genie_genie_ai_pypi_upstream.repository
  }
}

resource "aws_codeartifact_repository" "genie_genie_ai_pypi_upstream" {
  repository = "genie-genie-ai-pypi-upstream"
  domain     = aws_codeartifact_domain.outshift_codeartifact.domain

  external_connections {
    external_connection_name = "public:pypi"
  }
}

# Marvin venture
resource "aws_codeartifact_repository" "panoptica_marvin_private" {
  repository = "panoptica-marvin-private"
  domain     = aws_codeartifact_domain.outshift_codeartifact.domain

  upstream {
    repository_name = aws_codeartifact_repository.panoptica_marvin_pypi_upstream.repository
  }
}

resource "aws_codeartifact_repository" "panoptica_marvin_pypi_upstream" {
  repository = "panoptica-marvin-pypi-upstream"
  domain     = aws_codeartifact_domain.outshift_codeartifact.domain

  external_connections {
    external_connection_name = "public:pypi"
  }
}