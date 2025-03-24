resource "aws_eks_node_group" "private-nodegroup" {
  ami_type                = "CUSTOM"

  capacity_type           = "ON_DEMAND"
  disk_size               = "0"
  cluster_name            = "${var.name}"
  node_group_name_prefix  = "${var.name}-private-ng-"
  node_role_arn           = aws_iam_role.eks_nodegroup.arn
  subnet_ids              = [for subnet in data.aws_subnet.private : subnet.id]

  labels          = {}
  launch_template {
    id      = aws_launch_template.eks_node_launch_template.id
    version = "1"
  }

  instance_types  = [
    "m5a.2xlarge",
  ]

  scaling_config {
    desired_size = 6
    max_size     = 8
    min_size     = 4
  }

  update_config {
    max_unavailable_percentage = 33
  }

  depends_on = [ aws_launch_template.eks_node_launch_template ]
}