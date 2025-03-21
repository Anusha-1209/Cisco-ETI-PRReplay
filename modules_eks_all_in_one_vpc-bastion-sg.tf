locals {
  bastion_security_group      = join("", flatten([aws_security_group.bastion_host_security_group[*].id, var.bastion_security_group_id]))
}
resource "aws_security_group" "bastion_host_security_group" {
  count       = var.bastion_security_group_id == "" ? 1 : 0
  description = "Enable SSH access to the bastion host from external via SSH port"
  name        = "${local.name}-bastion"
  vpc_id      = local.vpc_id
}

resource "aws_security_group_rule" "ingress_bastion01" {

  count       = var.bastion_security_group_id == "" ? 1 : 0
  description = "Incoming traffic to bastion"
  type        = "ingress"
  from_port   = var.public_ssh_port
  to_port     = var.public_ssh_port
  protocol    = "TCP"
  /*cidr_blocks = concat(data.aws_subnet.subnets.*.cidr_block, var.cidrs)*/
  cidr_blocks       = var.cisco_cidrs
  security_group_id = local.bastion_security_group
}

resource "aws_security_group_rule" "ingress_bastion02" {

  count             = var.bastion_security_group_id == "" ? 1 : 0
  description       = "Incoming traffic to bastion"
  type              = "ingress"
  from_port         = var.public_ssh_port
  to_port           = var.public_ssh_port
  protocol          = "TCP"
  cidr_blocks       = concat(["${var.cidr}"])
  security_group_id = local.bastion_security_group
}

resource "aws_security_group_rule" "egress_bastion" {
  count = var.bastion_security_group_id == "" ? 1 : 0

  description = "Outgoing traffic from bastion to instances"
  type        = "egress"
  from_port   = "0"
  to_port     = "65535"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = local.bastion_security_group
}

resource "aws_security_group" "bastion-to-eks-private-nodes-security_group" {
  description = "Enable SSH access to the Private instances from the bastion via SSH port"
  name        = "${local.name}-bastion-to-eks-nodes"
  vpc_id      = local.vpc_id

  tags = merge(var.tags)
}

resource "aws_security_group_rule" "ingress_instances" {
  description = "Incoming traffic from bastion"
  type        = "ingress"
  from_port   = var.private_ssh_port
  to_port     = var.private_ssh_port
  protocol    = "TCP"

  source_security_group_id = local.bastion_security_group

  security_group_id = aws_security_group.bastion-to-eks-private-nodes-security_group.id
}
