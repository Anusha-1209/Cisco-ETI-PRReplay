provider "vault" {}

variable "venture_name" {
  type    = string
  default = "outshift-users" # <-- requires updating
}

variable "oidc_client_id" {
  type    = string
  default = "DII9TO378NM0ZW02ABST" # <-- requires updating
}

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/teamsecrets"
  alias     = "teamsecrets"
}

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
  alias     = "eticloud"
}

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/outshift-users" # <-- requires updating
  alias     = "venture"
}
resource "vault_namespace" "namespace" {
  provider = vault.eticloud
  path     = var.venture_name
}

# key-value secrets engine
resource "vault_mount" "genai" {
  provider = vault.venture
  path     = "genai"
  type     = "kv"
  options  = { version = "2" }
}

resource "vault_mount" "smith" {
  provider = vault.venture
  path     = "smith"
  type     = "kv"
  options  = { version = "2" }
}

resource "vault_mount" "ostinato" {
  provider = vault.venture
  path     = "ostinato"
  type     = "kv"
  options  = { version = "2" }
}

resource "vault_mount" "phoenix" {
  provider           = vault.venture
  path               = "phoenix"
  type               = "kv"
  options            = { version = "2" }
  listing_visibility = "hidden"
}

resource "vault_mount" "prcoach" {
  provider           = vault.venture
  path               = "prcoach"
  type               = "kv"
  options            = { version = "2" }
  listing_visibility = "hidden"
}

resource "vault_mount" "engineering_rd" {
  provider           = vault.venture
  path               = "engineering_rd"
  type               = "kv"
  options            = { version = "2" }
  listing_visibility = "hidden"
}

resource "vault_mount" "dmonkey" {
  provider           = vault.venture
  path               = "dmonkey"
  type               = "kv"
  options            = { version = "2" }
  listing_visibility = "hidden"
}

resource "vault_mount" "autosync" {
  provider           = vault.venture
  path               = "autosync"
  type               = "kv"
  options            = { version = "2" }
  listing_visibility = "hidden"
}

resource "vault_mount" "actionengine" {
  provider           = vault.venture
  path               = "actionengine"
  type               = "kv"
  options            = { version = "2" }
  listing_visibility = "hidden"
}

resource "vault_mount" "puccini" {
  provider           = vault.venture
  path               = "puccini"
  type               = "kv"
  options            = { version = "2" }
  listing_visibility = "hidden"
}

# OIDC Credentials
data "vault_generic_secret" "oidc_credential" {
  provider = vault.teamsecrets
  path     = "secret/cisco_sso_auth_clients/vault_oidc_creds"
}

# oidc auth backend
resource "vault_jwt_auth_backend" "oidc" {
  provider           = vault.venture
  type               = "oidc"
  path               = "oidc"
  oidc_client_id     = var.oidc_client_id
  oidc_client_secret = data.vault_generic_secret.oidc_credential.data["client_secret"]
  oidc_discovery_url = "https://sso-dbbfec7f.sso.duosecurity.com/oidc/${var.oidc_client_id}"
  default_role       = "generic-user"
}
