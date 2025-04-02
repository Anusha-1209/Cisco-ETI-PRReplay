data "vault_generic_secret" "llms_azure_openai_gpt4" {
  path = "autosync/llms/azure/openai/gpt4"
  provider = vault.venture
}

resource "vault_generic_secret" "bugbash_llms_azure_openai_gpt4" {
  path = "bugbash/llms/azure/openai/gpt4"
  provider = vault.venture
  data_json = data.vault_generic_secret.llms_azure_openai_gpt4.data_json
}