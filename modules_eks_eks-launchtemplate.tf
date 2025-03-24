resource "aws_launch_template" "eks_node_launch_template" {
  name_prefix               = "${var.name}-private-"
  image_id                  = "ami-06ddf84bd3b104fe6" # data.aws_ami.c9-eks.id

  key_name                  = aws_key_pair.eks_node_key_pair.key_name
  description               = "${var.name} Launch Template ${var.cluster_version}"
  disable_api_termination   = false
  disable_api_stop          = false
  security_group_names      = []
  user_data                 =  filebase64("./templates/linux_user_data.tpl")

  block_device_mappings {
    device_name     = "/dev/xvda"
    ebs {
      delete_on_termination = "true"
      encrypted             = "true"
      volume_size           = "100"
      volume_type           = "gp3"
      iops                  = 0
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    device_index                = 0
    delete_on_termination       = true
    ipv4_address_count          = 0
    ipv4_addresses              = []
    ipv4_prefix_count           = 0
    ipv4_prefixes               = []
    ipv6_address_count          = 0
    ipv6_addresses              = []
    ipv6_prefix_count           = 0
    ipv6_prefixes               = []
    network_card_index          = 0
    security_groups = [
      aws_security_group.node[0].id,
      data.aws_security_group.default.id
    ]
  }

  monitoring {
    enabled = true
  }

  depends_on = [ aws_key_pair.eks_node_key_pair, aws_security_group.node ]
}