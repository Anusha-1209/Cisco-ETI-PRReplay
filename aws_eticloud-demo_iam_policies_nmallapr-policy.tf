data "aws_iam_policy_document" "nmallapr-policy-doc" {
  statement {
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
      "eks:DescribeAddonVersions"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["iam:ListAccountAliases"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",

      # Let users fetch more information about images
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchCheckLayerAvailability",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "nmallapr-policy" {
  name        = "nmallapr-policy"
  path        = "/"
  description = "Nandu Mallapragada Policy"

  policy = data.aws_iam_policy_document.nmallapr-policy-doc.json
}
