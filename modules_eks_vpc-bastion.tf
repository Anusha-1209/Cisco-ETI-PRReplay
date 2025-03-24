locals {
  list_bastion_security_groups               = tolist([aws_security_group.bastion_host_security_group.id])
  concat_all_security_groups                 = concat(local.list_bastion_security_groups)
  compact_all_security_groups                = compact(local.concat_all_security_groups)
}

resource "aws_security_group" "bastion_host_security_group" {

  description = "Enable SSH access to the bastion host from external via SSH port"
  name        = "${var.name}-bastion"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "cisco_cidrs" {

  description       = "Incoming traffic to bastion"
  type              = "ingress"
  from_port         = var.public_ssh_port
  to_port           = var.public_ssh_port
  protocol          = "TCP"
  prefix_list_ids   = [aws_ec2_managed_prefix_list.cisco_internal_cidrs.id]
  security_group_id = aws_security_group.bastion_host_security_group.id
}

resource "aws_security_group_rule" "ingress_bastion02" {

  description       = "Incoming traffic to bastion"
  type              = "ingress"
  from_port         = var.public_ssh_port
  to_port           = var.public_ssh_port
  protocol          = "TCP"
  cidr_blocks       = values(data.aws_subnet.target).*.cidr_block
  security_group_id = aws_security_group.bastion_host_security_group.id
}

resource "aws_security_group_rule" "egress_bastion" {

  description = "Outgoing traffic from bastion to instances"
  type        = "egress"
  from_port   = "0"
  to_port     = "65535"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.bastion_host_security_group.id
}

resource "aws_security_group" "private_instances_security_group" {

  description = "Enable SSH access to the Private instances from the bastion via SSH port"
  name        = "${var.name}-priv-instances"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "ingress_instances" {
  depends_on               = [aws_security_group.private_instances_security_group]
  description              = "Incoming traffic from bastion"
  type                     = "ingress"
  from_port                = var.private_ssh_port
  to_port                  = var.private_ssh_port
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.private_instances_security_group.id
  security_group_id        = aws_security_group.private_instances_security_group.id
}

resource "aws_launch_template" "bastion_launch_template" {
  name_prefix            = var.name
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t3.nano"
  update_default_version = true
  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = toset(local.compact_all_security_groups)
    delete_on_termination       = true
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.bastion_host_profile.name
  }
  key_name = aws_key_pair.bastion_key_pair.key_name

  tag_specifications {
    resource_type = "instance"
    tags          = { "Name" = var.name }
  }

  tag_specifications {
    resource_type = "volume"
    tags          = { "Name" = var.name }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      image_id
    ]
  }
}

resource "aws_autoscaling_group" "bastion_auto_scaling_group" {
  name_prefix = "${var.name}-bastion"
  launch_template {
    id      = aws_launch_template.bastion_launch_template.id
    version = "$Latest"
  }
  max_size         = 1
  min_size         = 1
  desired_capacity = 1

  vpc_zone_identifier       = data.aws_subnets.public.ids

  default_cooldown          = 180
  health_check_grace_period = 180
  health_check_type         = "EC2"

  termination_policies = [
    "OldestLaunchConfiguration",
  ]

  tag {
    key                 = "Name"
    value               = "${var.name}-bastion"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

}

data "aws_iam_policy_document" "assume_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "bastion_host_policy_document" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "bastion_host_role" {
  name               = "${var.name}-bastion-host-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_policy_document.json
}

resource "aws_iam_policy" "bastion_host_policy" {
  name   = "${var.name}-host-policy"
  policy = data.aws_iam_policy_document.bastion_host_policy_document.json
}

resource "aws_iam_role_policy_attachment" "bastion_host" {
  policy_arn = aws_iam_policy.bastion_host_policy.arn
  role       = aws_iam_role.bastion_host_role.name
}

resource "aws_iam_instance_profile" "bastion_host_profile" {
  name = "${var.name}-bastion-profile"
  role = aws_iam_role.bastion_host_role.name
  path = "/"
}