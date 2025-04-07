data "aws_route53_zone" "route53_zone" {
  name         = "eticloud.io"
  private_zone = false
}