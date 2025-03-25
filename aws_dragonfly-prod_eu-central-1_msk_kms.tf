resource "aws_kms_key" "encryption_key" {
  description = "dragonfly-msk-prod-eu1 MSK cluster encryption key"
}
