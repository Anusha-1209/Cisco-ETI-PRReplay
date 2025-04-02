resource "aws_iam_policy" "maestro-developer-policy" {
  name = "maestro-developer-policy"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:*",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:s3:::maestro*"
          Sid      = "VisualEditor0"
        },
        {
          Action = [
            "ec2:*",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:ec2:::maestro*"
          Sid      = "VisualEditor2"
        },
        {
          Action = [
            "kafka:*",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:kafka:::maestro*"
          Sid      = "VisualEditor3"
        },
        {
          Action = [
            "lambda:*",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:lambda:::maestro*"
          Sid      = "VisualEditor4"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = var.tags
}
