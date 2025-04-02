data "aws_caller_identity" "current_outshift_common" {}
data "aws_eks_cluster" "test_cluster_marvin" {
  name = local.test_cluster_name
}
locals {
  test_cluster_name = "marvin-test-use2-1" # The name of the associated EKS cluster. Must be updated
  account_id = data.aws_caller_identity.current_outshift_common.account_id
  test_oidc_id    = trimprefix(data.aws_eks_cluster.test_cluster_marvin.identity[0].oidc[0].issuer, "https://")
}

resource "aws_iam_policy" "aws_s3_read_write_fail_over_requests_test_policy" {
  name        = "S3ReadWriteFailOverRequestsPolicy-${local.test_cluster_name}"
  description = "${local.test_cluster_name} AWS S3 Fail Over Requests IAM Policy"
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
        "Resource": "arn:aws:s3:::requests-failover-marvin-dev-use2-1*"
      }
    ]
  })
}


resource "aws_iam_policy" "aws_s3_kms_read_test_policy" {
  name        = "S3MKSReadPolicy-${local.test_cluster_name}"
  description = "${local.test_cluster_name} KMS Read Role IAM Policy"
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

resource "aws_iam_policy" "aws_s3-msk-connect-marvin-test-1_policy" {
  name        = "S3MSKConnectBatchProcssing-${local.test_cluster_name}"
  description = "${local.test_cluster_name} S3 MSK Connect Role IAM Policy"
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
        "Resource": "arn:aws:s3:::msk-connect-marvin-dev-use2-1*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:Get*",
          "s3:Put*",
          "s3:List*",
          "s3:Describe*"
        ],
        "Resource": "arn:aws:s3:::athena-results-marvin-dev-use2-1*"
      }
    ]
  })
}

resource "aws_iam_policy" "aws_sagemaker_invoke_endpoint_test_policy" {
  name        = "SageMakerInvokeEndpointPolicy-${local.test_cluster_name}"
  description = "${local.test_cluster_name} AWS Sage Maker Invoke Endpoint Policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "sagemaker:InvokeEndpoint",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_policy" "aws_sqs_collect_event_test_policy" {
  name        = "SQSMarvinCollectEvent-${local.test_cluster_name}"
  description = "${local.test_cluster_name} AWS SQS aws_sqs_collect_event_policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage"
      ],
      "Resource": "arn:aws:sqs:*:${local.account_id}:marvin-collect-events-test*"
    }]
  })
}

resource "aws_iam_policy" "aws_sqs_pre_process_collect_event_test_policy" {
  name        = "SQSMarvinPreProcessCollectEvent-${local.test_cluster_name}"
  description = "${local.test_cluster_name} AWS SQS aws_sqs_pre_process_collect_event_policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage"
      ],
      "Resource": "arn:aws:sqs:*:${local.account_id}:marvin-pre-process-collect-events-test*"
    }]
  })
}

resource "aws_iam_policy" "aws_comprehend_test_policy" {
  name        = "ComprehendPolicy-${local.test_cluster_name}"
  description = "${local.test_cluster_name} AWS Comprehend Policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "comprehend:*",
        ],
        "Resource": [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "aws_rds_iam_connect_test_policy" {
  name        = "RDSIAMConnectPolicy-${local.test_cluster_name}"
  description = "${local.test_cluster_name} AWS RDS Connect via IAM Policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "rds-db:connect"
        ],
        "Resource": [
          "arn:aws:rds-db:us-east-2:${local.account_id}:dbuser:cluster-C4DUCXANTKEFECHPMPYVN3SZTA/pgmarvin"
        ]
      }
    ]
  })
}


resource "aws_iam_role" "aws_marvin_producer_test_role" {
  name = "MarvinProducerRole-${local.test_cluster_name}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/${local.test_oidc_id}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.test_oidc_id}:aud": "sts.amazonaws.com",
            "${local.test_oidc_id}:sub": "system:serviceaccount:marvin-backend:producer"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role" "aws_marvin_batch_processing_test_role" {
  name = "MarvinBatchProcessingRole-${local.test_cluster_name}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/${local.test_oidc_id}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.test_oidc_id}:aud": "sts.amazonaws.com",
            "${local.test_oidc_id}:sub": "system:serviceaccount:marvin-backend:batch-processing"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role" "aws_marvin_prompt_inspection_test_role" {
  name = "MarvinPromptInspectionRole-${local.test_cluster_name}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/${local.test_oidc_id}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.test_oidc_id}:aud": "sts.amazonaws.com",
            "${local.test_oidc_id}:sub": "system:serviceaccount:marvin-backend:prompt-inspection"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role" "aws_marvin_auth_test_role" {
  name = "MarvinAuthRole-${local.test_cluster_name}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/${local.test_oidc_id}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.test_oidc_id}:aud": "sts.amazonaws.com",
            "${local.test_oidc_id}:sub": "system:serviceaccount:marvin-backend:auth"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role" "aws_marvin_forensic_test_role" {
  name = "MarvinForensicRole-${local.test_cluster_name}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/${local.test_oidc_id}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.test_oidc_id}:aud": "sts.amazonaws.com",
            "${local.test_oidc_id}:sub": "system:serviceaccount:marvin-backend:forensic"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "aws_marvin_producer_test_attachment" {
  role       = aws_iam_role.aws_marvin_producer_test_role.name
  policy_arn = aws_iam_policy.aws_s3_kms_read_test_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_marvin_producer_sqs_test_attachment" {
  role       = aws_iam_role.aws_marvin_producer_test_role.name
  policy_arn = aws_iam_policy.aws_sqs_collect_event_test_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_marvin_producer_comprehend_test_attachment" {
  role       = aws_iam_role.aws_marvin_producer_test_role.name
  policy_arn = aws_iam_policy.aws_comprehend_test_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_marvin_batch_processing_athena_test_attachment" {
  role       = aws_iam_role.aws_marvin_batch_processing_test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
}
resource "aws_iam_role_policy_attachment" "aws_marvin_batch_processing_rds_test_attachment" {
  role       = aws_iam_role.aws_marvin_batch_processing_test_role.name
  policy_arn = aws_iam_policy.aws_rds_iam_connect_test_policy.arn
}
resource "aws_iam_role_policy_attachment" "aws_marvin_batch_processing_s3_test_attachment" {
  role       = aws_iam_role.aws_marvin_batch_processing_test_role.name
  policy_arn = aws_iam_policy.aws_s3-msk-connect-marvin-test-1_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_marvin_prompt_inspection_test_attachment" {
  role       = aws_iam_role.aws_marvin_prompt_inspection_test_role.name
  policy_arn = aws_iam_policy.aws_s3_read_write_fail_over_requests_test_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_marvin_prompt_inspection_sage_maker_inference_test_attachment" {
  role       = aws_iam_role.aws_marvin_prompt_inspection_test_role.name
  policy_arn = aws_iam_policy.aws_sagemaker_invoke_endpoint_test_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_marvin_prompt_inspection_sqs_collect_events_test_attachment" {
  role       = aws_iam_role.aws_marvin_prompt_inspection_test_role.name
  policy_arn = aws_iam_policy.aws_sqs_collect_event_test_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_marvin_prompt_inspection_sqs_pre_process_collect_events_test_attachment" {
  role       = aws_iam_role.aws_marvin_prompt_inspection_test_role.name
  policy_arn = aws_iam_policy.aws_sqs_pre_process_collect_event_test_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_marvin_auth_rds_test_attachment" {
  role       = aws_iam_role.aws_marvin_auth_test_role.name
  policy_arn = aws_iam_policy.aws_rds_iam_connect_test_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_marvin_forensic_rds_test_attachment" {
  role       = aws_iam_role.aws_marvin_forensic_test_role.name
  policy_arn = aws_iam_policy.aws_rds_iam_connect_test_policy.arn
}
