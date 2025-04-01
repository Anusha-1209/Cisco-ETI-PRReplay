resource "aws_iam_policy" "cross-ac-access" {
  name        = "cross_ac_access"
  path        = "/"
  description = "client s3/pgres/redhift (eti-scratch) rw access for symphony-cerebrum"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.

  policy = jsonencode({
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:ListRoles",
          "sts:AssumeRole"
        ],
      "Resource" : "*"
      }
    ],
    "Version" : "2012-10-17"
  })

  tags = {
    Name = "cross_ac_access"
  }
}