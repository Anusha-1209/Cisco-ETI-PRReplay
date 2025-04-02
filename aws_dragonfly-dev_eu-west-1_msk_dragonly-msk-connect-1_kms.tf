resource "aws_kms_key" "encryption_key" {
  description = "encryption key for msk-kg-connector secrets"
}
