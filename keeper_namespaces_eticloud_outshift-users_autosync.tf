locals {
  gpt4_kv_paths = [
    "bugbash",
    "csm",
    "genai",
    "generic"
  ]

  mistral_kv_paths = [
    "bugbash",
    "csm",
    "genai",
    "generic"
  ]

  aws_bedrock_kv_paths = [
    "bugbash",
    "csm",
    "genai",
    "generic"
  ]

  gpt4o_kv_paths = [
    "bugbash",
    "genai"
  ]
  gpt4o-mini_kv_paths = [
    "genai"
  ]

  datasources_sharepoint_outshiftgenai_kv_paths = [
    "csm",
    "bugbash",
    "genai"
  ]

  datasources_sharepoint_ciscoeticloud_api_motific_rag_user_kv_paths = [
    "genai"
  ]

  datasources_sharepoint_ciscoeticloud_human_motific_rag_user1_kv_paths = [
    "genai"
  ]
}

data "vault_generic_secret" "autosync_llms_mistral" {
  path = "autosync/llms/mistral"
  provider = vault.venture
}

data "vault_generic_secret" "autosync_llms_aws_bedrock" {
  path = "autosync/llms/aws/bedrock"
  provider = vault.venture
}

# Sync GPT4 Key
data "vault_generic_secret" "autosync_llms_azure_openai_gpt4" {
  path = "autosync/llms/azure/openai/gpt4"
  provider = vault.venture
}

data "vault_generic_secret" "autosync_llms_azure_openai_gpt4o" {
  path = "autosync/llms/azure/openai/gpt4o"
  provider = vault.venture
}
data "vault_generic_secret" "autosync_llms_azure_openai_gpt4o-mini" {
  path = "autosync/llms/azure/openai/gpt4o-mini"
  provider = vault.venture
}
data "vault_generic_secret" "autosync_datasources_sharepoint_outshiftgenai" {
  path = "autosync/datasources/sharepoint/OutshiftGenAI"
  provider = vault.venture
}

data "vault_generic_secret" "autosync_datasources_sharepoint_ciscoeticloud_api_motific_rag_user" {
  path = "autosync/datasources/sharepoint/ciscoeticloud/api_users/motific-rag-user"
  provider = vault.venture
}

data "vault_generic_secret" "autosync_datasources_sharepoint_ciscoeticloud_human_motific_rag_user1" {
  path = "autosync/datasources/sharepoint/ciscoeticloud/human_users/motific_rag_user1"
  provider = vault.venture
}
resource "vault_generic_secret" "llms_mistral" {
  for_each = toset(local.mistral_kv_paths)
  provider = vault.venture
  data_json = data.vault_generic_secret.autosync_llms_mistral.data_json
  path = "${each.value}/llms/mistral"
}

resource "vault_generic_secret" "llms_aws_bedrock" {
  for_each = toset(local.aws_bedrock_kv_paths)
  provider = vault.venture
  data_json = data.vault_generic_secret.autosync_llms_aws_bedrock.data_json
  path = "${each.value}/llms/aws/bedrock"
}
resource "vault_generic_secret" "llms_azure_openai_gpt4" {
  for_each = toset(local.gpt4_kv_paths)
  provider = vault.venture
  data_json = data.vault_generic_secret.autosync_llms_azure_openai_gpt4.data_json
  path = "${each.value}/llms/azure/openai/gpt4"
}

resource "vault_generic_secret" "llms_azure_openai_gpt4o" {
  for_each = toset(local.gpt4o_kv_paths)
  provider = vault.venture
  data_json = data.vault_generic_secret.autosync_llms_azure_openai_gpt4o.data_json
  path = "${each.value}/llms/azure/openai/gpt4o"
}
resource "vault_generic_secret" "llms_azure_openai_gpt4o-mini" {
  for_each = toset(local.gpt4o-mini_kv_paths)
  provider = vault.venture
  data_json = data.vault_generic_secret.autosync_llms_azure_openai_gpt4o-mini.data_json
  path = "${each.value}/llms/azure/openai/gpt4o-mini"
}
resource "vault_generic_secret" "datasources_sharepoint_outshiftgenai" {
  for_each = toset(local.datasources_sharepoint_outshiftgenai_kv_paths)
  provider = vault.venture
  data_json = data.vault_generic_secret.autosync_datasources_sharepoint_outshiftgenai.data_json
  path = "${each.value}/datasources/sharepoint/OutshiftGenAI"
}

resource "vault_generic_secret" "datasources_sharepoint_ciscoeticloud_api_motific_rag_user" {
  for_each = toset(local.datasources_sharepoint_ciscoeticloud_api_motific_rag_user_kv_paths)
  provider = vault.venture
  data_json = data.vault_generic_secret.autosync_datasources_sharepoint_ciscoeticloud_api_motific_rag_user.data_json
  path = "${each.value}/datasources/sharepoint/ciscoeticloud/api_users/motific-rag-user"
}

resource "vault_generic_secret" "datasources_sharepoint_ciscoeticloud_human_motific_rag_user1" {
  for_each = toset(local.datasources_sharepoint_ciscoeticloud_human_motific_rag_user1_kv_paths)
  provider = vault.venture
  data_json = data.vault_generic_secret.autosync_datasources_sharepoint_ciscoeticloud_human_motific_rag_user1.data_json
  path = "${each.value}/datasources/sharepoint/ciscoeticloud/human_users/motific_rag_user1"
}