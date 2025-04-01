resource "aws_iam_role" "oncall" {
  name               = "oncall"
  assume_role_policy = data.aws_iam_policy_document.assume_role_with_saml.json
  tags = {
    Name = "oncall"
  }
}


resource "aws_iam_policy" "oncall-policy" {
  name        = "oncall-policy"
  path        = "/"
  description = "OnCall SSO IAM role access"
  policy = file("policies/oncall_policy.json")
}

###### SSO Access #######

resource "aws_iam_role_policy_attachment" "oncall-policy-attachment" {
  role       = aws_iam_role.oncall.name
  policy_arn = aws_iam_policy.oncall-policy.arn
}