data "aws_s3_bucket" "bucket" {
  bucket = "research-strapi-s3"
}

data "aws_iam_policy_document" "allow_strapi_access" {
  # Allow pulic read access
  statement {
    sid = "1"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    effect  = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      data.aws_s3_bucket.bucket.arn,
      "${data.aws_s3_bucket.bucket.arn}/*",
    ]
  }
# Allow access for the below AWS accounts
   statement {
    sid = "2"

    principals {
      type        = "AWS"
      identifiers = [       
        "arn:aws:iam::626007623524:user/websites-s3-access", # eticloud
        "arn:aws:iam::792074902331:user/websites-s3-access" # eticloud-preproduction
        ]
    }

    effect    = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      data.aws_s3_bucket.bucket.arn,
      "${data.aws_s3_bucket.bucket.arn}/*",
    ]
  }
}


