resource "aws_eip" "eip" {
  instance = module.ec2-instance.id
  tags = {
    "Name" = var.ec2_name
  }

  tags_all = {
    "Name" = var.ec2_name
  }
}

resource "aws_route53_record" "ec2_host_record_name" {
  name    = var.ec2_name
  zone_id = data.aws_route53_zone.this.id
  type    = "A"
  ttl     = 60
  records = [aws_eip.eip.public_ip]
}
