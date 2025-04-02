data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/eticcprod/infra/eticloud-scratch-c/aws"
}

resource "aws_iam_role" "meissa" {
  name = "meissa"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::244624147909:saml-provider/cloudsso.cisco.com"
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
    Name = "meissa"
  }
}


data "aws_iam_policy" "s3-meissa-rw" {
  name = "s3-meissa-rw"
}


###### SSO Access #######

resource "aws_iam_role_policy_attachment" "s3-meissa-rw-policy-attachment" {
  role       = aws_iam_role.meissa.name
  policy_arn = data.aws_iam_policy.s3-meissa-rw.arn
}
