data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/${local.eks_aws_account}/terraform_admin"
}