data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
  provider = vault.eticloud
}
data "aws_msk_cluster" "dragonfly_msk_1" {
  cluster_name = locals.msk_cluster_name
}
