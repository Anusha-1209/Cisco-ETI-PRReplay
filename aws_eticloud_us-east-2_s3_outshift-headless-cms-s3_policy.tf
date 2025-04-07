data "aws_s3_bucket" "bucket" {
  bucket = "outshift-headless-cms-s3"
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
      "s3:ListBucket"
    ]
    resources = [
      data.aws_s3_bucket.bucket.arn,
      "${data.aws_s3_bucket.bucket.arn}/*",
    ]
    condition {
      test     = "StringLike"
      variable = "aws:Referer"

      values = [
        "https://outshift-admin-panel.dev.eticloud.io/*",
        "https://outshift-admin-panel.staging.eticloud.io/*",
        "https://outshift-admin-panel.eticloud.io/*",

      ]
    }
   }
}


