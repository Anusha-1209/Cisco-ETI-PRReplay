resource "aws_kms_key" "encryption_key" {
  description = "${var.domain_name} encryption key"
}
