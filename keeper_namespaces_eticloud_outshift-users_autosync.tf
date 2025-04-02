locals {
  kv_paths = [
    "bugbash",
    "csm",
    "genai",
    "generic"]
}
data "vault_generic_secret" "autosync_llms_azure_openai_gpt4" {
  path = "autosync/llms/azure/openai/gpt4"
  provider = vault.venture
}


resource "vault_generic_secret" "llms_azure_openai_gpt4" {
  provider = vault.venture
  data_json = data.vault_generic_secret.autosync_llms_azure_openai_gpt4.data_json
  dynamic "path" {
    for_each = local.kv_paths
    content {
      path = "bugbash/${path.value}"
    }
  }
}