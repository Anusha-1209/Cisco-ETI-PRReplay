# Get the AWS account ID
data "aws_caller_identity" "current" {}


# Define the IAM policy for S3 access
data "aws_iam_policy_document" "s3_access" {
  statement {
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::${local.bucket_name}",
      "arn:aws:s3:::${local.bucket_name}/*"
    ]
  }
}

# Define the inline policy for MSK access
data "aws_iam_policy_document" "inference_client_policy" {
  statement {
    sid = "access"
    actions = [
      "kafka-cluster:Connect",
    ]
    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}"
    ]
    effect = "Allow"
  }

  statement {
    sid = "topic"
    actions = [
      "kafka-cluster:DescribeTopic",
      "kafka-cluster:ReadData",
    ]
    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/kg-node*",
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/kg-edge*",
    ]
    effect = "Allow"
  }

  statement {
    sid = "groups"
    actions = [
      "kafka-cluster:AlterGroup",
      "kafka-cluster:DescribeGroup",
    ]
    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/*",
    ]
    effect = "Allow"
  }
}

# Create the IAM role
resource "aws_iam_role" "eks_s3_access_role" {
  name = "${local.aws_account_name}-data-eks-s3-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_provider_url}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${local.eks_oidc_provider_url}:aud" = "sts.amazonaws.com",
            "${local.eks_oidc_provider_url}:sub" = "system:serviceaccount:dragonfly-backend:*"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/admin"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name   = "inference-client-policy"
    policy = data.aws_iam_policy_document.inference_client_policy.json
  }
}

# Attach the S3 access policy to the role
resource "aws_iam_policy" "s3_access_policy" {
  name   = "${local.aws_account_name}-data-s3-access-policy"
  policy = data.aws_iam_policy_document.s3_access.json
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.eks_s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# OIDC Provider URL
locals {
  eks_oidc_provider_url = "oidc.eks.${local.aws_region}.amazonaws.com/id/${local.eks_oidc_provider_id}"
}