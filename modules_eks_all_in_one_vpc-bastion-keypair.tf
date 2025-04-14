
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "vault_generic_secret" "private_key" {
  path      = "secret/infra/vpc/${local.name}/bastion/private_key"
  data_json = <<EOT
{
"private_key": "${replace(tls_private_key.ssh.private_key_pem, "\n", "\\n")}"
}
EOT
}

resource "vault_generic_secret" "public_key" {
  path      = "secret/infra/vpc/${local.name}/bastion/public_key"
  data_json = <<EOT
{
"public_key": "${replace(tls_private_key.ssh.public_key_openssh, "\n", "\\n")}"
}
EOT
}

resource "aws_key_pair" "bastion_key_pair" {
    key_name = "${local.name}-bastion-keypair"
    public_key = tls_private_key.ssh.public_key_openssh
}