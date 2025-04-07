data "aws_caller_identity" "current_efs" {}
data "aws_eks_cluster" "cluster_efs" {
  name = local.cluster_name_efs
}
locals {
  cluster_name_efs = "apisec-prod-1"
  account_id_efs = data.aws_caller_identity.current_efs.account_id
  oidc_id_efs    = trimprefix(data.aws_eks_cluster.cluster_efs.identity[0].oidc[0].issuer, "https://")
}


resource "aws_iam_role" "aws_efs_csi_driver_role" {
  name = "${local.cluster_name_efs}-AmazonEKS_EFS_CSI_DriverRole"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${local.account_id_efs}:oidc-provider/${local.oidc_id_efs}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "${local.oidc_id_efs}:aud": "sts.amazonaws.com",
                    "${local.oidc_id_efs}:sub": "system:serviceaccount:kube-system:efs-csi-*"
                }
            }
        }
    ]
  })
  force_detach_policies = true
}


resource "aws_iam_role_policy_attachment" "aws_efs_csi_driver_role_attachment" {
  role       = aws_iam_role.aws_efs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}
