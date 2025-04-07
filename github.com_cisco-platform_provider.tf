terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/github.com/cisco-eti/backend.tfstate"
    region = "us-east-2"
  }
  required_providers {
    sodium = {
      source  = "killmeplz/sodium"
      version = "~> 0.0.3"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}
provider "vault" {
  alias     = "eticloud_teamsecrets"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/teamsecrets"
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "generic_user_gh_token" {
  provider = vault.eticloud_teamsecrets
  path     = "secret/generic_users/eti-sre-cicd.gen"
}

# Configure the GitHub Provider
provider "github" {
  token = data.vault_generic_secret.generic_user_gh_token.data["TERRAFORM_ADMIN_GHEC_PAT"]
  owner = "cisco-platform" # CHANGE_ME: The owner of the repository
}
