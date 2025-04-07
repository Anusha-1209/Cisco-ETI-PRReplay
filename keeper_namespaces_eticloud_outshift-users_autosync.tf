locals {
  gpt4_kv_paths = [
    "genai"
  ]

  text_embedding_3_small_kv_paths = [
    "genai"
  ]

  text_embedding_3_large_kv_paths = [
    "genai"
  ]

  mistral_kv_paths = [
    "genai"
  ]

  aws_bedrock_kv_paths = [
    "genai"
  ]

  gpt4o_kv_paths = [
    "genai"
  ]

  gpt4o-mini_kv_paths = [
    "genai"
  ]

  datasources_sharepoint_outshiftgenai_kv_paths = [
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
  path     = "autosync/llms/mistral"
  provider = vault.venture
}

data "vault_generic_secret" "autosync_llms_aws_bedrock" {
  path     = "autosync/llms/aws/bedrock"
  provider = vault.venture
}

# Data retrieval for GPT4 Key
data "vault_generic_secret" "autosync_llms_azure_openai_gpt4" {
  path     = "autosync/llms/azure/openai/gpt4"
  provider = vault.venture
}

# Data retrieval for GPT4o Key
data "vault_generic_secret" "autosync_llms_azure_openai_gpt4o" {
  path     = "autosync/llms/azure/openai/gpt4o"
  provider = vault.venture
}

# Data retrieval for GPT4o-mini Key
data "vault_generic_secret" "autosync_llms_azure_openai_gpt4o-mini" {
  path     = "autosync/llms/azure/openai/gpt4o-mini"
  provider = vault.venture
}

# Data retrieval for text-embedding-3-small Key
data "vault_generic_secret" "autosync_llms_azure_openai_text_embedding_3_small" {
  path     = "autosync/llms/azure/openai/text-embedding-3-small"
  provider = vault.venture
}

# Data retrieval for text-embedding-3-large Key
data "vault_generic_secret" "autosync_llms_azure_openai_text_embedding_3_large" {
  path     = "autosync/llms/azure/openai/text-embedding-3-large"
  provider = vault.venture
}

# Data retrieval for Cisco Sharepoint Key
data "vault_generic_secret" "autosync_datasources_sharepoint_outshiftgenai" {
  path     = "autosync/datasources/sharepoint/OutshiftGenAI"
  provider = vault.venture
}

# Data retrieval for Outshift Private Sharepoint Client ID/Secret

data "vault_generic_secret" "autosync_datasources_sharepoint_ciscoeticloud_api_motific_rag_user" {
  path     = "autosync/datasources/sharepoint/ciscoeticloud/api_users/motific-rag-user"
  provider = vault.venture
}

# Data retrieval for Outshift Private Sharepoint Key
data "vault_generic_secret" "autosync_datasources_sharepoint_ciscoeticloud_human_motific_rag_user1" {
  path     = "autosync/datasources/sharepoint/ciscoeticloud/human_users/motific_rag_user1"
  provider = vault.venture
}

#########################################################

# Sync llms/mistral secrets to respective namespaces
resource "vault_generic_secret" "llms_mistral" {
  for_each  = toset(local.mistral_kv_paths)
  provider  = vault.venture
  data_json = data.vault_generic_secret.autosync_llms_mistral.data_json
  path      = "${each.value}/llms/mistral"
}

# Sync llms/aws/bedrock secrets to respective namespaces
resource "vault_generic_secret" "llms_aws_bedrock" {
  for_each  = toset(local.aws_bedrock_kv_paths)
  provider  = vault.venture
  data_json = data.vault_generic_secret.autosync_llms_aws_bedrock.data_json
  path      = "${each.value}/llms/aws/bedrock"
}

# Sync llms/azure/openai/gpt4 secrets to respective namespaces
resource "vault_generic_secret" "llms_azure_openai_gpt4" {
  for_each  = toset(local.gpt4_kv_paths)
  provider  = vault.venture
  data_json = data.vault_generic_secret.autosync_llms_azure_openai_gpt4.data_json
  path      = "${each.value}/llms/azure/openai/gpt4"
}

# Sync llms/azure/openai/gpt4o secrets to respective namespaces
resource "vault_generic_secret" "llms_azure_openai_gpt4o" {
  for_each  = toset(local.gpt4o_kv_paths)
  provider  = vault.venture
  data_json = data.vault_generic_secret.autosync_llms_azure_openai_gpt4o.data_json
  path      = "${each.value}/llms/azure/openai/gpt4o"
}

# Sync llms/azure/openai/gpt4o-mini secrets to respective namespaces
resource "vault_generic_secret" "llms_azure_openai_gpt4o-mini" {
  for_each  = toset(local.gpt4o-mini_kv_paths)
  provider  = vault.venture
  data_json = data.vault_generic_secret.autosync_llms_azure_openai_gpt4o-mini.data_json
  path      = "${each.value}/llms/azure/openai/gpt4o-mini"
}

# Sync llms/azure/openai/text-embedding-3-small secrets to respective namespaces
resource "vault_generic_secret" "llms_azure_openai_text_embedding_3_small" {
  for_each  = toset(local.text_embedding_3_small_kv_paths)
  provider  = vault.venture
  data_json = data.vault_generic_secret.autosync_llms_azure_openai_text_embedding_3_small.data_json
  path      = "${each.value}/llms/azure/openai/text-embedding-3-small"
}

# Sync llms/azure/openai/text-embedding-3-large secrets to respective namespaces
resource "vault_generic_secret" "llms_azure_openai_text_embedding_3_large" {
  for_each  = toset(local.text_embedding_3_large_kv_paths)
  provider  = vault.venture
  data_json = data.vault_generic_secret.autosync_llms_azure_openai_text_embedding_3_large.data_json
  path      = "${each.value}/llms/azure/openai/text-embedding-3-large"
}

# Sync Cisco Sharepoint secrets to respective namespaces
resource "vault_generic_secret" "datasources_sharepoint_outshiftgenai" {
  for_each  = toset(local.datasources_sharepoint_outshiftgenai_kv_paths)
  provider  = vault.venture
  data_json = data.vault_generic_secret.autosync_datasources_sharepoint_outshiftgenai.data_json
  path      = "${each.value}/datasources/sharepoint/OutshiftGenAI"
}

# Sync Outshift Private Sharepoint Azure Service Principle secrets to respective namespaces
resource "vault_generic_secret" "datasources_sharepoint_ciscoeticloud_api_motific_rag_user" {
  for_each  = toset(local.datasources_sharepoint_ciscoeticloud_api_motific_rag_user_kv_paths)
  provider  = vault.venture
  data_json = data.vault_generic_secret.autosync_datasources_sharepoint_ciscoeticloud_api_motific_rag_user.data_json
  path      = "${each.value}/datasources/sharepoint/ciscoeticloud/api_users/motific-rag-user"
}

# Sync Outshift Private Sharepoint Azure Human User secrets to respective namespaces
resource "vault_generic_secret" "datasources_sharepoint_ciscoeticloud_human_motific_rag_user1" {
  for_each  = toset(local.datasources_sharepoint_ciscoeticloud_human_motific_rag_user1_kv_paths)
  provider  = vault.venture
  data_json = data.vault_generic_secret.autosync_datasources_sharepoint_ciscoeticloud_human_motific_rag_user1.data_json
  path      = "${each.value}/datasources/sharepoint/ciscoeticloud/human_users/motific_rag_user1"
}