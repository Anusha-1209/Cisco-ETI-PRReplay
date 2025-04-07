resource "aws_ssm_parameter" "gha_token" {
  name  = "gha-token"
  type  = "String"
  value = data.vault_generic_secret.gha_token.data["gha-token"]
}
