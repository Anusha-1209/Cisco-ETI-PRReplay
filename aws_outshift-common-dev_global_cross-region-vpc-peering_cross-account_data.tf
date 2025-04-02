data "vault_generic_secret" "aws_infra_credentials_accepter" {

  path     = "secret/infra/aws/${local.accepter_account}/terraform_admin"
  provider = vault.eticloud
}

data "vault_generic_secret" "aws_infra_credentials_requester" {

  path     = "secret/infra/aws/${local.requester_account}/terraform_admin"
  provider = vault.eticloud
}

# Use this to get the account ID
data "aws_caller_identity" "current" {
  provider = aws.peer
}

data "aws_region" "requester" {
  provider = aws.peer
}
data "aws_region" "accepter" {
  provider = aws.this
}