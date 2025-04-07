data "aws_caller_identity" "current_apisec_aws" {}
data "aws_eks_cluster" "cluster_apisec" {
  name = local.cluster_name_apisec
}
locals {
  cluster_name_apisec = "apisec-staging-1"
  account_id_apisec = data.aws_caller_identity.current_apisec_aws.account_id
  oidc_id_apisec    = trimprefix(data.aws_eks_cluster.cluster_apisec.identity[0].oidc[0].issuer, "https://")
}

resource "aws_iam_policy" "aws_s3_read_write_fail_over_requests_policy" {
  name        = "S3ReadWriteFailOverRequestsPolicy-${local.cluster_name_apisec}"
  description = "${local.cluster_name_apisec} AWS S3 Fail Over Requests IAM Policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:Get*",
          "s3:Put*",
          "s3:List*",
          "s3:Describe*"
        ],
        "Resource": "arn:aws:s3:::marvin-staging-fail-over-requests*"
      }
    ]
  })
}

resource "aws_iam_policy" "aws_s3_msk_connect_marvin_policy" {
  name        = "S3MskConnectMarvinPolicy-${local.cluster_name_apisec}"
  description = "${local.cluster_name_apisec} AWS MSK Connect Role IAM Policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:Get*",
          "s3:Put*",
          "s3:List*",
          "s3:Describe*"
        ],
        "Resource": "arn:aws:s3:::msk-connect-marvin-staging-1*"
      }
    ]
  })
}

resource "aws_iam_policy" "aws_s3_kms_read_policy" {
  name        = "S3MKSReadPolicy-${local.cluster_name_apisec}"
  description = "${local.cluster_name_apisec} KMS Read Role IAM Policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "kms:DescribeKey",
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "secretsmanager:*"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject"
        ],
        "Resource": [
          "arn:aws:s3:::secrets-manager-rotation-apps-*/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "aws_s3-msk-connect-marvin-staging-1_policy" {
  name        = "S3MSKConnectBatchProcssing-${local.cluster_name_apisec}"
  description = "${local.cluster_name_apisec} S3 MSK Connect Role IAM Policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:Get*",
          "s3:Put*",
          "s3:List*",
          "s3:Describe*"
        ],
        "Resource": "arn:aws:s3:::msk-connect-marvin-staging-1*"
      }
    ]
  })
}

resource "aws_iam_role" "aws_marvin_producer_role" {
  name = "MarvinProducerRole-${local.cluster_name_apisec}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${local.account_id_apisec}:oidc-provider/${local.oidc_id_apisec}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.oidc_id_apisec}:aud": "sts.amazonaws.com",
            "${local.oidc_id_apisec}:sub": "system:serviceaccount:marvin-backend:producer"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role" "aws_marvin_batch_processing_role" {
  name = "MarvinBatchProcessingRole-${local.cluster_name_apisec}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${local.account_id_apisec}:oidc-provider/${local.oidc_id_apisec}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.oidc_id_apisec}:aud": "sts.amazonaws.com",
            "${local.oidc_id_apisec}:sub": "system:serviceaccount:marvin-backend:batch-processing"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role" "aws_marvin_prompt_inspection_role" {
  name = "MarvinPromptInspectionRole-${local.cluster_name_apisec}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${local.account_id_apisec}:oidc-provider/${local.oidc_id_apisec}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.oidc_id_apisec}:aud": "sts.amazonaws.com",
            "${local.oidc_id_apisec}:sub": "system:serviceaccount:marvin-backend:prompt-inspection"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "aws_marvin_producer_attachment" {
  role       = aws_iam_role.aws_marvin_producer_role.name
  policy_arn = aws_iam_policy.aws_s3_kms_read_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_marvin_batch_processing_athena_attachment" {
  role       = aws_iam_role.aws_marvin_batch_processing_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
}
resource "aws_iam_role_policy_attachment" "aws_marvin_batch_processing_s3_attachment" {
  role       = aws_iam_role.aws_marvin_batch_processing_role.name
  policy_arn = aws_iam_policy.aws_s3-msk-connect-marvin-staging-1_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_marvin_prompt_inspection_attachment" {
  role       = aws_iam_role.aws_marvin_prompt_inspection_role.name
  policy_arn = aws_iam_policy.aws_s3_read_write_fail_over_requests_policy.arn
}

#resource "aws_iam_role_policy_attachment" "aws_marvin_prompt_inspection_sagemaker_attachment" {
#  role       = aws_iam_role.aws_marvin_prompt_inspection_role.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
#}