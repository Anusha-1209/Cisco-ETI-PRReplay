# Instance profile for legacy karpenter
# resource "aws_iam_instance_profile" "ip" {
#   provider = aws.eks
#   name = "KarpenterNodeInstanceProfile-${local.name}"
#   role = "KarpenterNodeRole-${local.name}"
# }