data "aws_caller_identity" "current_ebs" {}

data "aws_eks_cluster" "cluster_ebs" {
  name = local.cluster_name_ebs
}
locals {
  cluster_name_ebs = "apisec-dev-1"
  account_id_ebs = data.aws_caller_identity.current_ebs.account_id
  oidc_id_ebs    = trimprefix(data.aws_eks_cluster.cluster_ebs.identity[0].oidc[0].issuer, "https://")
}

resource "aws_iam_role" "aws_ebs_csi_driver_role" {
  name                  = "${local.cluster_name_ebs}-AmazonEKS_EBS_CSI_DriverRole"
  assume_role_policy =  jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${local.account_id_ebs}:oidc-provider/${local.oidc_id_ebs}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${local.oidc_id_ebs}:aud": "sts.amazonaws.com",
                    "${local.oidc_id_ebs}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
                }
            }
        }
    ]
}

  )
  force_detach_policies = true
}


resource "aws_iam_role_policy_attachment" "aws_ebs_csi_driver_role_attachment" {
  role       = aws_iam_role.aws_ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
