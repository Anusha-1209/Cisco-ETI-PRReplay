resource "aws_kms_key" "encryption_key" {
  description = "dragonfly-msk-1 MSK cluster encryption key"
}
