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
}


resource "aws_security_group" "marvin-staging-1-msk" {
  name        = "marvin-staging-1-msk-default"
  description = "marvin-staging-1-msk MSK cluster default security group"
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

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
