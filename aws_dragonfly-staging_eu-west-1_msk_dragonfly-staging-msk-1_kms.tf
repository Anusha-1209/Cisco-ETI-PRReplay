resource "aws_kms_key" "encryption_key" {
  description = "dragonfly-staging-msk-1 MSK cluster encryption key"
}
