data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/infra/aws/eticloud-scratch-c/terraform_admin"
}
