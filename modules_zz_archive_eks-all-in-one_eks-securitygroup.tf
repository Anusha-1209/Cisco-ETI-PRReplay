locals {
  node_sg_name   = coalesce(var.node_security_group_name, "${var.name}-node")
  create_node_sg = var.create && var.create_node_security_group

  node_security_group_id = local.create_node_sg ? aws_security_group.node[0].id : var.node_security_group_id

  node_security_group_rules = {
    ingress_cluster_443 = {
      description                   = "Cluster API to node groups"
      protocol                      = "tcp"
      from_port                     = 443
      to_port                       = 443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_cluster_kubelet = {
      description                   = "Cluster API to node kubelets"
      protocol                      = "tcp"
      from_port                     = 10250
      to_port                       = 10250
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_self_coredns_tcp = {
      description = "Node to node CoreDNS"
      protocol    = "tcp"
      from_port   = 53
      to_port     = 53
      type        = "ingress"
      self        = true
    }
    ingress_self_coredns_udp = {
      description = "Node to node CoreDNS UDP"
      protocol    = "udp"
      from_port   = 53
      to_port     = 53
      type        = "ingress"
      self        = true
    }
  }

  node_security_group_recommended_rules = { for k, v in {
    ingress_nodes_ephemeral = {
      description = "Node to node ingress on ephemeral ports"
      protocol    = "tcp"
      from_port   = 1025
      to_port     = 65535
      type        = "ingress"
      self        = true
    }
    # metrics-server
    ingress_cluster_4443_webhook = {
      description                   = "Cluster API to node 4443/tcp webhook"
      protocol                      = "tcp"
      from_port                     = 4443
      to_port                       = 4443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    # prometheus-adapter
    ingress_cluster_6443_webhook = {
      description                   = "Cluster API to node 6443/tcp webhook"
      protocol                      = "tcp"
      from_port                     = 6443
      to_port                       = 6443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    # Karpenter
    ingress_cluster_8443_webhook = {
      description                   = "Cluster API to node 8443/tcp webhook"
      protocol                      = "tcp"
      from_port                     = 8443
      to_port                       = 8443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    # ALB controller, NGINX
    ingress_cluster_9443_webhook = {
      description                   = "Cluster API to node 9443/tcp webhook"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_all = {
      description      = "Allow all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = var.cluster_ip_family == "ipv6" ? ["::/0"] : null
    }
  } : k => v if var.node_security_group_enable_recommended_rules }
}

resource "aws_security_group" "node" {
  count = local.create_node_sg ? 1 : 0

  name        = var.node_security_group_use_name_prefix ? null : local.node_sg_name
  name_prefix = var.node_security_group_use_name_prefix ? "${local.node_sg_name}${var.prefix_separator}" : null
  description = var.node_security_group_description
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Name"                                      = local.node_sg_name
      "kubernetes.io/cluster/${var.name}" = "owned"
    },
    var.node_security_group_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "node" {
  for_each = { for k, v in merge(
    local.node_security_group_rules,
    local.node_security_group_recommended_rules,
    var.node_security_group_additional_rules,
  ) : k => v if local.create_node_sg }

  # Required
  security_group_id = aws_security_group.node[0].id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = each.value.type

  # Optional
  description              = lookup(each.value, "description", null)
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", [])
  self                     = lookup(each.value, "self", null)
  source_security_group_id = try(each.value.source_cluster_security_group, false) ? local.cluster_security_group_id : lookup(each.value, "source_security_group_id", null)
}

# resource "aws_security_group" "node" {
#   name_prefix = "eks-node-"

#   ingress {
#     from_port = 0
#     to_port   = 65535
#     protocol  = "tcp"
#     cidr_blocks = [
#       "0.0.0.0/0"
#     ]
#   }

#   egress {
#     from_port = 0
#     to_port   = 65535
#     protocol  = "tcp"
#     cidr_blocks = [
#       "0.0.0.0/0"
#     ]
#   }
# }

# resource "aws_security_group_rule" "node_ingress" {
#   type        = "ingress"
#   from_port   = 0
#   to_port     = 65535
#   protocol    = "tcp"
#   cidr_blocks = [
#     "0.0.0.0/0"
#   ]

#   security_group_id = aws_security_group.node.id
# }