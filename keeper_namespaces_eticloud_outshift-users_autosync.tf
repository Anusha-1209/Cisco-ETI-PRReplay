locals {
  gpt4_kv_paths = [
    "bugbash",
    "csm",
    "genai",
    "generic"
    ]

  gpt4o_kv_paths = [
    "genai"
    ]
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