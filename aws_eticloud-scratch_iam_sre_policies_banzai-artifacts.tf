resource "aws_iam_policy" "banzai-artifacts" {
  name = "banzai-artifacts"
  path = "/"
  policy = jsonencode(
    {
      "Statement" : [
        {
          "Sid" : "binaries",
          "Effect" : "Allow",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::cisco-eti-banzai-binaries/*"
        },
        {
          "Sid" : "charts",
          "Effect" : "Allow",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::cisco-eti-banzai-charts/*"
        }
      ]
      Version = "2012-10-17"
    }
  )
  tags = var.tags
}