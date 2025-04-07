data "aws_ssm_parameter" "outshift_platform_gha_token" {
  name            = "gha-token"
  type            = "SecureString"
  with_decryption = false
}
