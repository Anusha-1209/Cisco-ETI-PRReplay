data "aws_caller_identity" "current_outshift_common" {}
data "aws_eks_cluster" "cluster_marvin" {
  name = local.cluster_name
}
locals {
  cluster_name = "marvin-prod-use2-1" # The name of the associated EKS cluster. Must be updated
  account_id = data.aws_caller_identity.current_outshift_common.account_id
  oidc_id    = trimprefix(data.aws_eks_cluster.cluster_marvin.identity[0].oidc[0].issuer, "https://")
}

resource "aws_iam_policy" "aws_rds_iam_connect_policy" {
  name        = "RDSIAMConnectPolicy-${local.cluster_name}"
  description = "${local.cluster_name} AWS RDS Connect via IAM Policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "rds-db:connect"
        ],
        "Resource": [
          "arn:aws:rds-db:us-east-2:${local.account_id}:dbuser:cluster-PWCSZNHVYBDK4C3TACFRRKDY3M/pgmarvin"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "aws_s3_read_write_fail_over_requests_policy" {
  name        = "S3ReadWriteFailOverRequestsPolicy-${local.cluster_name}"
  description = "${local.cluster_name} AWS S3 Fail Over Requests IAM Policy"
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
        "Resource": "arn:aws:s3:::requests-failover-marvin-prod-use2-1*"
      }
    ]
  })
}


resource "aws_iam_policy" "aws_s3_kms_read_policy" {
  name        = "S3MKSReadPolicy-${local.cluster_name}"
  description = "${local.cluster_name} KMS Read Role IAM Policy"
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
  name        = "S3MSKConnectBatchProcssing-${local.cluster_name}"
  description = "${local.cluster_name} S3 MSK Connect Role IAM Policy"
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
        "Resource": "arn:aws:s3:::msk-connect-marvin-prod-use2-1*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:Get*",
          "s3:Put*",
          "s3:List*",
          "s3:Describe*"
        ],
        "Resource": "arn:aws:s3:::athena-results-marvin-prod-use2-1*"
      }
    ]
  })
}

resource "aws_iam_role" "aws_marvin_producer_role" {
  name = "MarvinProducerRole-${local.cluster_name}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_id}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.oidc_id}:aud": "sts.amazonaws.com",
            "${local.oidc_id}:sub": "system:serviceaccount:marvin-backend:producer"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role" "aws_marvin_batch_processing_role" {
  name = "MarvinBatchProcessingRole-${local.cluster_name}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_id}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.oidc_id}:aud": "sts.amazonaws.com",
            "${local.oidc_id}:sub": "system:serviceaccount:marvin-backend:batch-processing"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role" "aws_marvin_prompt_inspection_role" {
  name = "MarvinPromptInspectionRole-${local.cluster_name}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_id}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.oidc_id}:aud": "sts.amazonaws.com",
            "${local.oidc_id}:sub": "system:serviceaccount:marvin-backend:prompt-inspection"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role" "aws_marvin_auth_role" {
  name = "MarvinAuthRole-${local.cluster_name}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_id}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.oidc_id}:aud": "sts.amazonaws.com",
            "${local.oidc_id}:sub": "system:serviceaccount:marvin-backend:auth"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role" "aws_marvin_forensic_role" {
  name = "MarvinForensicRole-${local.cluster_name}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_id}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.oidc_id}:aud": "sts.amazonaws.com",
            "${local.oidc_id}:sub": "system:serviceaccount:marvin-backend:forensic"
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
resource "aws_iam_role_policy_attachment" "aws_marvin_batch_processing_rds_attachment" {
  role       = aws_iam_role.aws_marvin_batch_processing_role.name
  policy_arn = aws_iam_policy.aws_rds_iam_connect_policy.arn
}
resource "aws_iam_role_policy_attachment" "aws_marvin_batch_processing_s3_attachment" {
  role       = aws_iam_role.aws_marvin_batch_processing_role.name
  policy_arn = aws_iam_policy.aws_s3-msk-connect-marvin-staging-1_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_marvin_prompt_inspection_attachment" {
  role       = aws_iam_role.aws_marvin_prompt_inspection_role.name
  policy_arn = aws_iam_policy.aws_s3_read_write_fail_over_requests_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_marvin_auth_rds_attachment" {
  role       = aws_iam_role.aws_marvin_auth_role.name
  policy_arn = aws_iam_policy.aws_rds_iam_connect_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_marvin_forensic_rds_attachment" {
  role       = aws_iam_role.aws_marvin_forensic_role.name
  policy_arn = aws_iam_policy.aws_rds_iam_connect_policy.arn
}
