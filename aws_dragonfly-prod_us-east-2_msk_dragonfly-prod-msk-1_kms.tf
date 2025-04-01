resource "aws_kms_key" "encryption_key" {
  description = "dragonfly-msk-prod-1 MSK cluster encryption key"
}
