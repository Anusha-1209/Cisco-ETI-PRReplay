locals {
  name                                = var.name
  ami_id                              = var.ami_id != "" ? var.ami_id : data.aws_ami.eks_default_cisco.image_id
  cluster_os                          = "Ubuntu20"
  iam_role_policy_prefix              = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
  cluster_auth_base64                 = aws_eks_cluster.this[0].certificate_authority[0].data
  cluster_endpoint                    = aws_eks_cluster.this[0].endpoint

  aws_auth_configmap_string           = concat(
    [
      {
        rolearn  = aws_iam_role.eks_ng_aws_iam_role[0].arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
        ]
      },
      {
        rolearn  = aws_iam_role.eks_aws_iam_role[0].arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
        ]
      },
      {
        rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/admin",
        username = "admin",
        groups   = ["system:masters"]
      },
      {
        rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sre-audit-ro",
        username = "sre-audit-ro",
        groups   = ["view"]
      }
    ])
    aws_auth_configmap_yaml = {
      mapRoles = yamlencode(local.aws_auth_configmap_string)
    }

}