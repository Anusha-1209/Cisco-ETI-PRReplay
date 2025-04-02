locals {
  ingress_rules = []

  egress_rules = [
    {
      from_port : 8529,
      to_port : 8529,
      protocol : "tcp",
      cidr_blocks : [
        data.aws_vpc.msk_vpc.cidr_block,
        data.aws_vpc.eks_vpc.cidr_block,
      ],
    },
  ]
}


resource "aws_security_group" "dragonfly_kg_1" {
  name        = "dragonfly-msk-1-msk-default"
  description = "dragonfly-msk-1 MSK cluster default security group"
  vpc_id      = data.aws_vpc.msk_vpc.id

  dynamic "ingress" {
    for_each = toset(local.ingress_rules)

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = toset(local.egress_rules)

    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}
