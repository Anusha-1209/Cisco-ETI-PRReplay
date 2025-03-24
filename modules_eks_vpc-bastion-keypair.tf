locals {
  vault_path = format("secret/infra/eks/%s", var.name)
}

resource "tls_private_key" "bastion_ssh" {
  algorithm  = "RSA"
  rsa_bits   = 4096
}

resource "vault_generic_secret" "private_key" {
  provider   = vault.eticloud
  path       = "${local.vault_path}/private_key"
  data_json  = <<EOT
{
"private_key": "${replace(tls_private_key.bastion_ssh.private_key_pem, "\n", "\\n")}"
}
EOT
}

resource "vault_generic_secret" "public_key" {
  provider  = vault.eticloud
  path      = "${local.vault_path}/public_key"
  data_json = <<EOT
{
"public_key": "${replace(tls_private_key.bastion_ssh.public_key_openssh, "\n", "\\n")}"
}
EOT
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name   = "${var.name}-bastion"
  public_key = tls_private_key.bastion_ssh.public_key_openssh
}