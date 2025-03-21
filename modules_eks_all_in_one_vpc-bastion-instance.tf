resource "aws_launch_template" "bastion_launch_template" {
  name_prefix                   = "${local.name}-bastion"
  image_id                      = local.ami_id
  instance_type                 = var.bastion_instance_type
  update_default_version        = true
  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = var.bastion_associate_public_ip_address
    security_groups             = concat([local.bastion_security_group], var.bastion_additional_security_groups)
    delete_on_termination       = true
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.bastion_host_profile.name
  }

  key_name = aws_key_pair.bastion_key_pair.key_name

  user_data = try(local.platform[var.platform].user_data, null)

  tag_specifications {
    resource_type = "instance"
    tags          = merge(tomap({"Name"= "${local.name}-bastion-lt"}), merge(var.tags))
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(tomap({"Name"= "${local.name}-bastion-lt"}), merge(var.tags))
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      image_id
    ]
  }
}

resource "aws_autoscaling_group" "bastion_auto_scaling_group" {
  name_prefix = "${local.name}-bastion"
  launch_template {
    id      = aws_launch_template.bastion_launch_template.id
    version = "$Latest"
  }

  max_size         = var.bastion_instance_count
  min_size         = var.bastion_instance_count
  desired_capacity = var.bastion_instance_count

  vpc_zone_identifier = aws_subnet.private[*].id

  default_cooldown          = 180
  health_check_grace_period = 180
  health_check_type         = "EC2"

  termination_policies = [
    "OldestLaunchConfiguration",
  ]

  tag {
    key                 = "Name"
    value               = "${local.name}-bastion"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

}

data "aws_iam_policy_document" "bastion_host_assume_policy_document" {
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

resource "aws_iam_role" "bastion_host_role" {
  name               = "${local.name}-bastion-host-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.bastion_host_assume_policy_document.json
}

resource "aws_iam_instance_profile" "bastion_host_profile" {
  name = "${local.name}-bastion-profile"
  role = aws_iam_role.bastion_host_role.name
  path = "/"
}