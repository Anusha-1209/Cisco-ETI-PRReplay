# Create the IAM user secret engine will use to auth against AWS
resource "aws_iam_user" "vault-secret-engine-user-eticloud" {
  name = "vault-secret-engine-user-eticloud"
}

resource "aws_iam_access_key" "vault-secret-engine-user-eticloud" {
  user = aws_iam_user.vault-secret-engine-user-eticloud.name
}

resource "aws_iam_user_policy" "vault-secret-engine-user-eticloud" {
  name = "vault-secret-engine-user-eticloud"
  user = aws_iam_user.vault-secret-engine-user-eticloud.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "arn:aws:iam::626007623524:role/ci-ecr-push",
        "arn:aws:iam::626007623524:role/ci-helm-push",
        "arn:aws:iam::626007623524:role/ci-default",
        "arn:aws:iam::626007623524:role/great-bear"
      ]
    }
  ]
}
EOF
}


## ci-ecr-push role and policy

resource "aws_iam_role" "ci-ecr-push" {
  name               = "ci-ecr-push"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::626007623524:user/vault-secret-engine-user-eticloud"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "ci-ecr-push"
  }
}

resource "aws_iam_policy" "ci-ecr-push-policy" {
  name        = "ci-ecr-push-policy"
  description = "write access to ECR for CI artifact storage"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                "ecr-public:DeleteRepositoryPolicy",
                "ecr-public:UntagResource",
                "ecr-public:DescribeRegistries",
                "ecr-public:BatchDeleteImage",
                "ecr:BatchGetRepositoryScanningConfiguration",
                "ecr-public:DeleteRepository",
                "ecr-public:InitiateLayerUpload",
                "ecr:TagResource",
                "ecr-public:PutRegistryCatalogData",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetLifecyclePolicy",
                "ecr-public:PutRepositoryCatalogData",
                "ecr:DescribeImageScanFindings",
                "ecr:CreateRepository",
                "ecr-public:CreateRepository",
                "ecr:PutImageScanningConfiguration",
                "ecr:GetDownloadUrlForLayer",
                "ecr:DescribePullThroughCacheRules",
                "ecr:GetAuthorizationToken",
                "ecr-public:GetRepositoryPolicy",
                "ecr:PutImage",
                "ecr-public:PutImage",
                "ecr:UntagResource",
                "ecr:BatchGetImage",
                "ecr:DescribeImages",
                "ecr-public:ListTagsForResource",
                "ecr:InitiateLayerUpload",
                "ecr:PutImageTagMutability",
                "ecr:DescribeImageReplicationStatus",
                "ecr:ListTagsForResource",
                "ecr:UploadLayerPart",
                "ecr:CreatePullThroughCacheRule",
                "ecr:ListImages",
                "ecr:PutRegistryPolicy",
                "ecr:GetRegistryScanningConfiguration",
                "ecr-public:SetRepositoryPolicy",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "sts:GetServiceBearerToken",
                "ecr:ReplicateImage",
                "ecr-public:DescribeImageTags",
                "ecr:GetRegistryPolicy",
                "ecr:PutLifecyclePolicy",
                "ecr-public:DescribeImages",
                "ecr-public:UploadLayerPart",
                "ecr-public:GetAuthorizationToken",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:DescribeRegistry",
                "ecr-public:GetRepositoryCatalogData",
                "ecr:PutRegistryScanningConfiguration",
                "ecr-public:TagResource",
                "ecr-public:CompleteLayerUpload",
                "ecr-public:DescribeRepositories",
                "ecr:BatchImportUpstreamImage",
                "ecr:SetRepositoryPolicy",
                "ecr-public:GetRegistryCatalogData",
                "ecr-public:BatchCheckLayerAvailability",
                "ecr:GetRepositoryPolicy",
                "ecr:PutReplicationConfiguration"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ecr-public:GetAuthorizationToken",
        "sts:GetServiceBearerToken"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ci-ecr-push-policy-attach" {
  role       = aws_iam_role.ci-ecr-push.name
  policy_arn = aws_iam_policy.ci-ecr-push-policy.arn
}

## ci-helm-push role and policy

resource "aws_iam_role" "ci-helm-push" {
  name               = "ci-helm-push"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::626007623524:user/vault-secret-engine-user-eticloud"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "ci-helm-push"
  }
}

resource "aws_iam_policy" "ci-helm-s3-write-policy" {
  name        = "ci-helm-s3-write-policy"
  description = "write access to S3 for CI helm artifact storage"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::eti-helm-charts-private",
        "arn:aws:s3:::cisco-eti-banzai-charts",
        "arn:aws:s3:::cisco-eti-banzai-binaries"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::eti-helm-charts-private/*",
        "arn:aws:s3:::cisco-eti-banzai-charts/*",
        "arn:aws:s3:::cisco-eti-banzai-binaries/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ci-helm-s3-write-policy-attach" {
  role       = aws_iam_role.ci-helm-push.name
  policy_arn = aws_iam_policy.ci-helm-s3-write-policy.arn
}

## ci-default role and policy attachments

resource "aws_iam_role" "ci-default" {
  name               = "ci-default"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::626007623524:user/vault-secret-engine-user-eticloud"
        },
        "Action" : "sts:AssumeRole"
      },
      {
          "Effect": "Allow",
          "Principal": {
              "AWS": "arn:aws:iam::626007623524:root"
          },
          "Action": "sts:AssumeRole",
          "Condition": {}
      }
    ]
  })

  tags = {
    Name = "ci-default"
  }
}

resource "aws_iam_role_policy_attachment" "ci-default-s3-write-policy-attach" {
  role       = aws_iam_role.ci-default.name
  policy_arn = aws_iam_policy.ci-helm-s3-write-policy.arn
}

resource "aws_iam_role_policy_attachment" "ci-default-ecr-push-policy-attach" {
  role       = aws_iam_role.ci-default.name
  policy_arn = aws_iam_policy.ci-ecr-push-policy.arn
}

## ci-s3-bucket role and policy attachments

resource "aws_iam_role" "ci-s3-bucket" {
  name               = "ci-s3-bucket"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::626007623524:user/vault-secret-engine-user-eticloud"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "ci-s3-bucket"
  }
}

resource "aws_iam_policy" "ci-s3-write-policy" {
  name        = "ci-s3-write-policy"
  description = "write access to S3 storage"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::panoptica-internal-cli-binary",
        "arn:aws:s3:::panoptica-cli-binary"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::panoptica-internal-cli-binary/*",
        "arn:aws:s3:::panoptica-cli-binary/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ci-s3-write-policy-attach" {
  role       = aws_iam_role.ci-s3-bucket.name
  policy_arn = aws_iam_policy.ci-s3-write-policy.arn
}
