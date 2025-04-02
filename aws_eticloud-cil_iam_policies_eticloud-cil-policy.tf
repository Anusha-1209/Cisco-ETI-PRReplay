data "aws_iam_policy_document" "eticloud-cil-policy-doc" {
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

}

resource "aws_iam_policy" "eticloud-cil-policy" {
  name        = "eticloud-cil-policy"
  path        = "/"
  description = "eticloud-cil account Policy"

  policy = data.aws_iam_policy_document.eticloud-cil-policy-doc.json
}