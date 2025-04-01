resource "aws_iam_role" "kosha-ses" {
  name = "kosha-ses"

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
    Name = "kosha"
  }
}


data "aws_iam_policy" "kosha-ses-rw" {
  name = "kosha-ses-rw"
}


###### SSO Access #######

resource "aws_iam_role_policy_attachment" "kosha-ses-rw-policy-attachment" {
  role       = aws_iam_role.kosha-ses.name
  policy_arn = data.aws_iam_policy.kosha-ses-rw.arn
}
