# IAM policy that allows to list a specific bucket and write objects to it
resource "aws_iam_policy" "plg_write_to_s3" {
  name        = "WriteToPLGAnalyticsS3Bucket"
  description = "IAM policy that allows to write to a specific S3 bucket"

  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Sid" = "ListObjectsInBucket",
        "Effect" = "Allow",
        "Action" = [
          "s3:ListBucket"
        ],
        "Resource" = "arn:aws:s3:::eti-plg-analytics-s3-bucket/Rosey/*"
      },
       {
        "Sid" = "AllObjectActions",
        "Effect" = "Allow",
        "Action" = [
          "s3:PutObject"
        ],
        "Resource" = "*"
      }
    ]
  })
}

# IAM role for each cluster we want to export metrics from
resource "aws_iam_role" "plg_write_to_s3" {
  name     = "WriteToPLGAnalyticsS3Bucket"
  assume_role_policy = jsonencode()
}

resource "aws_iam_role_policy_attachment" "amp_ingest_policy" {
  role       = aws_iam_role.plg_write_to_s3.name
  policy_arn = aws_iam_policy.plg_write_to_s3.arn
}
