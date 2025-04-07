resource "aws_iam_policy" "chef_eval_s3_admin_policy" {
  name        = "chef-eval-s3-admin-policy"
  description = "chef-eval S3 Admin Role IAM Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::chef-eval",
          "arn:aws:s3:::chef-eval/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "chef_eval_s3_admin_role" {
  name = "chef-eval-s3-admin-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::471112537430:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27:sub" : "system:serviceaccount:chef-dev:*"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "chef_eval_s3_admin_attachment" {
  role       = aws_iam_role.chef_eval_s3_admin_role.name
  policy_arn = aws_iam_policy.chef_eval_s3_admin_policy.arn
}