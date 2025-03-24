locals {
  eks_node_vault_path = format("secret/infra/vpc/%s/%s", var.name, "bastion")
}

resource "tls_private_key" "eks_node_ssh" {
  algorithm  = "RSA"
  rsa_bits   = 4096
}

resource "vault_generic_secret" "eks_node_private_key" {
  provider   = vault.eticloud
  path       = "${local.eks_node_vault_path}/private_key"
  data_json  = <<EOT
{
"private_key": "${replace(tls_private_key.eks_node_ssh.private_key_pem, "\n", "\\n")}"
}
EOT
}

resource "vault_generic_secret" "eks_node_public_key" {
  provider  = vault.eticloud
  path      = "${local.eks_node_vault_path}/public_key"
  data_json = <<EOT
{
"public_key": "${replace(tls_private_key.eks_node_ssh.public_key_openssh, "\n", "\\n")}"
}
EOT
}

resource "aws_key_pair" "eks_node_key_pair" {
  key_name   = "${var.name}-eks"
  public_key = tls_private_key.eks_node_ssh.public_key_openssh
}
