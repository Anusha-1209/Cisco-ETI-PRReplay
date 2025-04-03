resource "aws_iam_role" "readonly" {
  name               = "readonly"
  assume_role_policy = data.aws_iam_policy_document.assume_role_with_saml.json
  tags = {
    Name = "readonly"
  }
}
resource "aws_iam_policy" "EKSReadOnlyAccess" {
  name        = "oncall-policy"
  path        = "/"
  description = "EKS Read Only Access"
  policy = file("policies/EKSReadOnlyAccess.json")
}

###### SSO Access #######

resource "aws_iam_role_policy_attachment" "readonly-policy-attachment" {
  role       = aws_iam_role.readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
resource "aws_iam_role_policy_attachment" "readonly-policy-attachment" {
  role       = aws_iam_role.readonly.name
  policy_arn = aws_iam_policy.EKSReadOnlyAccess.arn
}