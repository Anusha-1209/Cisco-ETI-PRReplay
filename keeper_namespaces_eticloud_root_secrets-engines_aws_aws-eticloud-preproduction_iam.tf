# Create the IAM user secret engine will use to auth against AWS
resource "aws_iam_user" "vault-secret-engine-user-eticloud-preproduction" {
  name     = "vault-secret-engine-user-eticloud-preproduction"
  provider = aws.preprod
}

resource "aws_iam_access_key" "vault-secret-engine-user-eticloud-preproduction" {
  user     = aws_iam_user.vault-secret-engine-user-eticloud-preproduction.name
  provider = aws.preprod
}

resource "aws_iam_user_policy" "vault-secret-engine-user-eticloud-preproduction" {
  name     = "vault-secret-engine-user-eticloud-preproduction"
  user     = aws_iam_user.vault-secret-engine-user-eticloud-preproduction.name
  provider = aws.preprod
  policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "${aws_iam_role.eticloud-preproduction-greatbear-ci-role.arn}",
        "${aws_iam_role.ci-default-role.arn}"
      ]
    }
  ]
}
EOF
  
}


## greatbear ci role and policy

resource "aws_iam_role" "eticloud-preproduction-greatbear-ci-role" {
  name               = "eticloud-preproduction-greatbear-ci"
  provider           = aws.preprod
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${aws_iam_user.vault-secret-engine-user-eticloud-preproduction.arn}"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = "eticloud-preproduction-greatbear-ci-role"
  }
}

resource "aws_iam_policy" "eticloud-preproduction-greatbear-ci-policy" {
    name        = "eticloud-preproduction-greatbear-ci-policy"
    provider    = aws.preprod
    description = "Access to preproduction for greatbear ci"
    policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "ecr:*",
        "eks:ListFargateProfiles",
        "eks:DescribeNodegroup",
        "eks:ListNodegroups",
        "eks:ListUpdates",
        "eks:AccessKubernetesApi",
        "eks:ListAddons",
        "eks:DescribeCluster",
        "eks:DescribeAddonVersions",
        "eks:ListClusters",
        "eks:ListIdentityProviderConfigs",
        "iam:ListRoles"
      ],
      "Resource": "*"
    }
  ]
}
    EOF
}

resource "aws_iam_role_policy_attachment" "eticloud-preproduction-greatbear-ci-policy-attach" {
  provider   = aws.preprod  
  role       = aws_iam_role.eticloud-preproduction-greatbear-ci-role.name
  policy_arn = aws_iam_policy.eticloud-preproduction-greatbear-ci-policy.arn
}

resource "aws_iam_role" "ci-default-role" {
  provider           = aws.preprod
  name               = "ci-default"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::792074902331:user/vault-secret-engine-user-eticloud-preproduction"
        },
        "Action" : "sts:AssumeRole"
      },
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::792074902331:root"
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

resource "aws_iam_role_policy_attachment" "eticloud-preproduction-ci-policy-attach" {
  provider   = aws.preprod
  role       = aws_iam_role.eticloud-preproduction-greatbear-ci-role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
