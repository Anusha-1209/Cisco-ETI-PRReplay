# Karpenter IAM resources for the dragonfly-prod-1 EKS cluster
# To migrate to the EKS module when nodes can be rotated
data "aws_caller_identity" "current" {}
data "aws_eks_cluster" "cluster" {
  name = local.eks_name
}

# locals
locals {
  account_id         = data.aws_caller_identity.current.account_id
  account_name       = "dragonfly-production"
  oidc_id            = trimprefix(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://")
  vpc_name           = "dragonfly-prod-euc1-1"
  eks_name           = "dragonfly-prod-euc1-1"
  aws_default_region = "eu-central-1"
}

resource "aws_iam_policy" "aws_karpenter_controller_policy" {
  name        = "KarpenterControllerPolicy-${local.eks_name}"
  description = "${local.eks_name} AWS Karpenter Controller Role IAM Policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "ssm:GetParameter",
          "ec2:DescribeImages",
          "ec2:RunInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateTags",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:DescribeSpotPriceHistory",
          "pricing:GetProducts"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "Karpenter"
      },
      {
        "Action" : "ec2:TerminateInstances",
        "Condition" : {
          "StringLike" : {
            "ec2:ResourceTag/karpenter.sh/nodepool" : "*"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "ConditionalEC2Termination"
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:PassRole",
        "Resource" : "arn:aws:iam::${local.account_id}:role/KarpenterNodeRole-${local.eks_name}",
        "Sid" : "PassNodeIAMRole"
      },
      {
        "Effect" : "Allow",
        "Action" : "eks:DescribeCluster",
        "Resource" : "arn:aws:eks:${local.aws_default_region}:${local.account_id}:cluster/${local.eks_name}",
        "Sid" : "EKSClusterEndpointLookup"
      },
      {
        "Sid" : "AllowScopedInstanceProfileCreationActions",
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : [
          "iam:CreateInstanceProfile"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestTag/kubernetes.io/cluster/${local.eks_name}" : "owned",
            "aws:RequestTag/topology.kubernetes.io/region" : "${local.aws_default_region}"
          },
          "StringLike" : {
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass" : "*"
          }
        }
      },
      {
        "Sid" : "AllowScopedInstanceProfileTagActions",
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : [
          "iam:TagInstanceProfile"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/kubernetes.io/cluster/${local.eks_name}" : "owned",
            "aws:ResourceTag/topology.kubernetes.io/region" : "${local.aws_default_region}",
            "aws:RequestTag/kubernetes.io/cluster/${local.eks_name}" : "owned",
            "aws:RequestTag/topology.kubernetes.io/region" : "${local.aws_default_region}"
          },
          "StringLike" : {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass" : "*",
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass" : "*"
          }
        }
      },
      {
        "Sid" : "AllowScopedInstanceProfileActions",
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : [
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/kubernetes.io/cluster/${local.eks_name}" : "owned",
            "aws:ResourceTag/topology.kubernetes.io/region" : "${local.aws_default_region}"
          },
          "StringLike" : {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass" : "*"
          }
        }
      },
      {
        "Sid" : "AllowInstanceProfileReadActions",
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : "iam:GetInstanceProfile"
      }
    ]

  })
}

resource "aws_iam_role" "aws_karpenter_controller_role" {
  name = "KarpenterControllerRole-${local.eks_name}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_id}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.oidc_id}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}


resource "aws_iam_role" "aws_karpenter_node_role" {
  name = "KarpenterNodeRole-${local.eks_name}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "aws_karpenter_controller_attachment" {
  role       = aws_iam_role.aws_karpenter_controller_role.name
  policy_arn = aws_iam_policy.aws_karpenter_controller_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_karpenter_node_attachment_1" {
  role       = aws_iam_role.aws_karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "aws_karpenter_node_attachment_2" {
  role       = aws_iam_role.aws_karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "aws_karpenter_node_attachment_3" {
  role       = aws_iam_role.aws_karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "aws_karpenter_node_attachment_4" {
  role       = aws_iam_role.aws_karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "aws_karpenter_node_attachment_5" {
  role       = aws_iam_role.aws_karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
