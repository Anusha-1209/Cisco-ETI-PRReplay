resource "aws_iam_policy" "ecr-syc-ro" {
  name        = "ecr-syc-ro"
  path        = "/"
  description = "ecr access for symphony-cerebrum"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ListImagesInRepository",
        "Effect" : "Allow",
        "Action" : [
          "ecr:ListImages"
        ],
        "Resource" : "arn:aws:ecr:us-east-2:626007623524:repository/syc-run-all-models"
      },
      {
        "Sid" : "GetAuthorizationToken",
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowPull",
        "Effect" : "Allow",
        "Action" : [
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer"
        ],
        "Resource" : "arn:aws:ecr:us-east-2:626007623524:repository/syc-run-all-models"
      }
    ]
  })

  tags = {
    Name = "ecr-syc-ro"
  }
}
