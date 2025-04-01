resource "aws_iam_role" "eti-identity" {
  name = "eti-identity"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::626007623524:saml-provider/cloudsso.cisco.com"
        },
        "Action" : "sts:AssumeRoleWithSAML",
        "Condition" : {
          "StringEquals" : {
            "SAML:aud" : "https://signin.aws.amazon.com/saml"
          }
        }
      }
    ]
  })

  tags = {
    Name = "eti-identity"
  }
}


data "aws_iam_policy" "eti-identity-policy" {
  name = "eti-identity-policy"
}


###### SSO Access #######

resource "aws_iam_role_policy_attachment" "eti-identity-policy-attachment" {
  role       = aws_iam_role.eti-identity.name
  policy_arn = data.aws_iam_policy.eti-identity-policy.arn
}
