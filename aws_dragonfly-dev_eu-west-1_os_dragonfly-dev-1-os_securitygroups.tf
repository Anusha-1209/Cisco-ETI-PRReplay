locals {
  msk_ingress_rules = [
    {
      from_port : 443,
      to_port : 443,
      protocol : "tcp",
      cidr_blocks : [
        data.aws_vpc.compute_vpc.cidr_block,
      ],
    },
  ]

  msk_egress_rules = []
}


resource "aws_security_group" "dragonfly_dev_1_os" {
  name        = "${var.domain_name}-default"
  description = "${var.domain_name} opensearch cluster default security group"
  vpc_id      = data.aws_vpc.database_vpc.id

  dynamic "ingress" {
    for_each = toset(local.msk_ingress_rules)

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = toset(local.msk_egress_rules)

    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}
