resource "aws_iam_policy" "developer_access" {
  name        = "developer-access"
  path        = "/"
  description = "IAM Policy to allow developers EKS Access"
  policy      = file("./resources/eks_developer_access-policy.json")
}


resource "aws_iam_role" "developer_access" {
  name                  = "developer-access"
  assume_role_policy    = file("./resources/saml_cloudsso-role-policy.json")
  force_detach_policies = true
}


resource "aws_iam_role_policy_attachment" "developer_access" {
  role       = aws_iam_role.developer_access.name
  policy_arn = aws_iam_policy.developer_access.arn
}
