// BUILD RUNNERS

// Runner 1
resource "aws_eip" "eip_build_runner_1" {
  instance = module.ec2-instance-build-runner-1.id
  tags = {
    "Name" = "outshift-build-runner-1"
  }

  tags_all = {
    "Name" = "outshift-build-runner-1"
  }
}

resource "aws_route53_record" "ec2_host_record_name_build_runner_1" {
  name    = "outshift-build-runner-1"
  zone_id = data.aws_route53_zone.this.id
  type    = "A"
  ttl     = 60
  records = [aws_eip.eip_build_runner_1.public_ip]
}

// Runner 2
resource "aws_eip" "eip_build_runner_2" {
  instance = module.ec2-instance-build-runner-2.id
  tags = {
    "Name" = "outshift-build-runner-2"
  }

  tags_all = {
    "Name" = "outshift-build-runner-2"
  }
}

resource "aws_route53_record" "ec2_host_record_name_build_runner_2" {
  name    = "outshift-build-runner-2"
  zone_id = data.aws_route53_zone.this.id
  type    = "A"
  ttl     = 60
  records = [aws_eip.eip_build_runner_2.public_ip]
}

// Runner 3
resource "aws_eip" "eip_build_runner_3" {
  instance = module.ec2-instance-build-runner-3.id
  tags = {
    "Name" = "outshift-build-runner-3"
  }

  tags_all = {
    "Name" = "outshift-build-runner-3"
  }
}

resource "aws_route53_record" "ec2_host_record_name_build_runner_3" {
  name    = "outshift-build-runner-3"
  zone_id = data.aws_route53_zone.this.id
  type    = "A"
  ttl     = 60
  records = [aws_eip.eip_build_runner_3.public_ip]
}

// JARVIS RUNNERS

// Runner 1
resource "aws_eip" "eip_jarvis_runner_1" {
  instance = module.ec2-instance-jarvis-runner-1.id
  tags = {
    "Name" = "outshift-jarvis-runner-1"
  }

  tags_all = {
    "Name" = "outshift-jarvis-runner-1"
  }
}

resource "aws_route53_record" "ec2_host_record_name_jarvis_runner_1" {
  name    = "outshift-jarvis-runner-1"
  zone_id = data.aws_route53_zone.this.id
  type    = "A"
  ttl     = 60
  records = [aws_eip.eip_jarvis_runner_1.public_ip]
}

// Runner 2
resource "aws_eip" "eip_jarvis_runner_2" {
  instance = module.ec2-instance-jarvis-runner-2.id
  tags = {
    "Name" = "outshift-jarvis-runner-2"
  }

  tags_all = {
    "Name" = "outshift-jarvis-runner-2"
  }
}

resource "aws_route53_record" "ec2_host_record_name_jarvis_runner_2" {
  name    = "outshift-jarvis-runner-1"
  zone_id = data.aws_route53_zone.this.id
  type    = "A"
  ttl     = 60
  records = [aws_eip.eip_jarvis_runner_2.public_ip]
}
