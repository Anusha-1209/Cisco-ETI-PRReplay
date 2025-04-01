resource "aws_iam_policy" "devopsAllEKS" {
  description = "created for access to EKS"
  name        = "devopsAllEKS"
  path        = "/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "eks:ListNodegroups",
            "eks:ListTagsForResource",
            "eks:ListAddons",
            "eks:UpdateClusterConfig",
            "eks:CreateNodegroup",
            "eks:DescribeAddon",
            "eks:DescribeNodegroup",
            "eks:DescribeIdentityProviderConfig",
            "eks:DescribeUpdate",
            "eks:TagResource",
            "eks:AccessKubernetesApi",
            "eks:UpdateNodegroupConfig",
            "eks:DescribeCluster",
            "eks:ListIdentityProviderConfigs",
            "eks:AssociateIdentityProviderConfig",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:eks:*:380642323071:addon/*/*/*",
            "arn:aws:eks:*:380642323071:nodegroup/*/*/*",
            "arn:aws:eks:*:380642323071:cluster/*",
            "arn:aws:eks:*:380642323071:fargateprofile/*/*/*",
            "arn:aws:eks:*:380642323071:identityproviderconfig/*/*/*/*",
          ]
          Sid = "VisualEditor0"
        },
        {
          Action = [
            "eks:ListClusters",
            "eks:DescribeAddonVersions",
            "eks:CreateCluster",
          ]
          Effect   = "Allow"
          Resource = "*"
          Sid      = "VisualEditor1"
        },
        {
          Action = "eks:*"
          Effect = "Allow"
          Resource = [
            "arn:aws:eks:*:380642323071:addon/*/*/*",
            "arn:aws:eks:*:380642323071:nodegroup/*/*/*",
            "arn:aws:eks:*:380642323071:cluster/*",
          ]
          Sid = "VisualEditor2"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags     = var.tags
  tags_all = {}
}