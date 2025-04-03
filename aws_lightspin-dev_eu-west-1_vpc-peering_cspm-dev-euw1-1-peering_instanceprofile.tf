locals {
  name             = "cspm-dev-euw1-1"
}


# Instance profile for legacy karpenter
resource "aws_iam_instance_profile" "ip" {
  name = "KarpenterNodeInstanceProfile-${local.name}"
  role = "KarpenterNodeRole-${local.name}"
}