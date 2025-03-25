locals {
  msk_ingress_rules = [
    {
      from_port : 9094,
      to_port : 9094,
      protocol : "tcp",
      cidr_blocks : [
        data.aws_vpc.msk_vpc.cidr_block,
        data.aws_vpc.eks_vpc.cidr_block,
      ],
    },
    {
      from_port : 9096,
      to_port : 9096,
      protocol : "tcp",
      cidr_blocks : [
        data.aws_vpc.msk_vpc.cidr_block,
        data.aws_vpc.eks_vpc.cidr_block,
      ],
    },
    {
      from_port : 9098,
      to_port : 9098,
      protocol : "tcp",
      cidr_blocks : [
        data.aws_vpc.msk_vpc.cidr_block,
        data.aws_vpc.eks_vpc.cidr_block,
      ],
    },
    {
      from_port : 2181,
      to_port : 2181,
      protocol : "tcp",
      cidr_blocks : [
        data.aws_vpc.msk_vpc.cidr_block,
      ],
    },
  ]

  msk_egress_rules = [
    {
      from_port : 0,
      to_port : 65535,
      protocol : "tcp",
      cidr_blocks : [
        data.aws_vpc.msk_vpc.cidr_block,
        data.aws_vpc.eks_vpc.cidr_block,
      ],
    },
  ]
}


resource "aws_security_group" "dragonfly_msk_eu1" {
  name        = "dragonfly-msk-prod-eu1-msk-default"
  description = "dragonfly-msk-prod-eu1 MSK cluster default security group"
  vpc_id      = data.aws_vpc.msk_vpc.id

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
