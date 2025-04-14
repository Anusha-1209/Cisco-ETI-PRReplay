
resource "tls_private_key" "bastion_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "vault_generic_secret" "bastion_private_key" {
  path      = "secret/infra/vpc/${local.name}/bastion/private_key"
  data_json = <<EOT
{
"private_key": "${replace(tls_private_key.bastion_ssh.private_key_pem, "\n", "\\n")}"
}
EOT
}

resource "vault_generic_secret" "bastion_public_key" {
  path      = "secret/infra/vpc/${local.name}/bastion/public_key"
  data_json = <<EOT
{
"public_key": "${replace(tls_private_key.bastion_ssh.public_key_openssh, "\n", "\\n")}"
}
EOT
}

resource "aws_key_pair" "bastion_key_pair" {
    key_name = "${local.name}-bastion-keypair"
    public_key = tls_private_key.bastion_ssh.public_key_openssh
}