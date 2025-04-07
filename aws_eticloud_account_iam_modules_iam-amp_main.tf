locals {
  cluster_name_for_iam = upper(replace(var.cluster_name, "-", ""))
  oidc_issuer          = trimprefix(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://")
}

# EKS cluster where the OTEL collector will be deployed
data "aws_eks_cluster" "eks_cluster" {
  provider = aws.src
  name     = var.cluster_name
}

# IAM policy that grants read/write permissions to AMP
resource "aws_iam_policy" "amp_ingest_policy" {
  provider    = aws.dst
  name        = "${var.cluster_name}-AMPIngestPolicy"
  description = "Ingest policy for AMP"

  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Effect" = "Allow",
        "Action" = [
          "aps:RemoteWrite",
          "aps:GetSeries",
          "aps:GetLabels",
          "aps:GetMetricMetadata"
        ],
        "Resource" = "*"
      }
    ]
  })
}

# IAM role for each cluster we want to export metrics from
resource "aws_iam_role" "amp_iamproxy_ingest" {
  provider = aws.dst
  name     = "${var.cluster_name}-AMPIngestRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = local.cluster_name_for_iam
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_account}:oidc-provider/${local.oidc_issuer}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_issuer}:aud" : "sts.amazonaws.com",
            "${local.oidc_issuer}:sub": "system:serviceaccount:opentelemetry-collector:${var.cluster_name}-opentelemetry-collector"
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amp_ingest_policy" {
  provider   = aws.dst
  role       = aws_iam_role.amp_iamproxy_ingest.name
  policy_arn = aws_iam_policy.amp_ingest_policy.arn
}


# Add new OIDC provider for each new EKS cluster to onboard
data "external" "thumbprint" {
  provider = external
  program = [
    "/bin/sh",
    "${path.module}/external/thumbprint",
    var.cluster_region,
  ]
}

resource "aws_iam_openid_connect_provider" "openid_connect_provider" {
  provider = aws.dst
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = [
    data.external.thumbprint.result.thumbprint,
  ]
}
