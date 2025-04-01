resource "aws_iam_policy" "appnet-create-role" {
  name   = "appnet-create-role"
  policy = jsonencode(
        {
            Statement = [
                {
                    Action   = [
                        "ec2:AuthorizeSecurityGroupIngress",
                        "iam:DetachRolePolicy",
                        "iam:DeleteRolePolicy",
                        "ec2:DeleteSecurityGroup",
                        "iam:CreateRole",
                        "iam:DeleteRole",
                        "iam:AttachRolePolicy",
                        "ec2:ModifyVpcAttribute",
                        "iam:DeleteRolePermissionsBoundary",
                        "iam:DeleteOpenIDConnectProvider",
                        "ec2:DescribeSecurityGroups",
                        "iam:CreateOpenIDConnectProvider",
                    ]
                    Effect   = "Allow"
                    Resource = "*"
                    Sid      = "VisualEditor0"
                },
            ]
            Version   = "2012-10-17"
        }
    )
  tags = var.tags
}