resource "aws_s3_bucket" "outshift_product_analytics" {
  bucket = "outshift-product-analytics-s3-bucket"
}

data "aws_iam_policy_document" "data_sync_from_cnapp_prod_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.cnapp_prod_account_id}:role/source-datasync-role"]
    }

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging"
    ]

    resources = [
      aws_s3_bucket.outshift_product_analytics.arn,
      "${aws_s3_bucket.outshift_product_analytics.arn}/Rosey/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "data_sync_from_cnapp_prod_account" {
  bucket = aws_s3_bucket.outshift_product_analytics.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}
