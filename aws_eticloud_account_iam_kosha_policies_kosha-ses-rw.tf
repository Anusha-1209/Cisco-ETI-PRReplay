resource "aws_iam_policy" "kosha-ses-rw" {
  name        = "kosha-ses-rw"
  path        = "/"
  description = "SES rw access for kosha"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
            "ses:*",
            "iam:ListAccountAliases"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = {
    Name = "kosha-ses-rw"
  }
}
