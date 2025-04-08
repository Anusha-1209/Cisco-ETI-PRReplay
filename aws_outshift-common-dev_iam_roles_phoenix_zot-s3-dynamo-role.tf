
resource "aws_iam_policy" "zot_s3_dynamo_policy" {
  name        = "zot-s3-dynamo-policy"
  description = "IAM Policy to grant permissions to phoenix s3 zot bucket"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads"
        ],
        "Resource" : "arn:aws:s3:::outshift-zot-dev-bucket"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ],
        "Resource" : "arn:aws:s3:::outshift-zot-dev-bucket/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:CreateTable",
          "dynamodb:DescribeTable",
          "dynamodb:ListTables"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        "Resource" : "arn:aws:dynamodb:*:*:table/ZotBlobTable"
      }
    ]
  })
}

resource "aws_iam_role" "zot_s3_dynamo_role" {
  name = "zot-s3-dynamo-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::471112537430:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27:sub" : "system:serviceaccount:phoenix:zot-sa"
          }
        }
      }
    ]
  })

  force_detach_policies = false
}

resource "aws_iam_role_policy_attachment" "zot_s3_dynamo_role_policy_attachment" {
  role       = aws_iam_role.zot_s3_dynamo_role.name
  policy_arn = aws_iam_policy.zot_s3_dynamo_policy.arn
}
