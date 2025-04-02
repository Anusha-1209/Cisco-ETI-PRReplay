locals {
  gpt4_kv_paths = [
    "bugbash",
    "csm",
    "genai",
    "generic"]
}

# Sync GPT4 Key
data "vault_generic_secret" "autosync_llms_azure_openai_gpt4" {
  path = "autosync/llms/azure/openai/gpt4"
  provider = vault.venture
}


resource "vault_generic_secret" "llms_azure_openai_gpt4" {
  for_each = local.gpt4_kv_paths
  provider = vault.venture
  data_json = data.vault_generic_secret.autosync_llms_azure_openai_gpt4.data_json
  path = "${each.value}/llms/azure/openai/gpt4"
}