resource "aws_iam_policy" "ETI_SRE_Jenkins_EKS" {
  name = "ETI_SRE_Jenkins_EKS"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "iam:*",
                "ecr:*",
                "sts:*",
                "eks:DescribeCluster",
                "eks:ListClusters",
                "eks:DescribeAddonVersions",
                "ecr-public:*",
                "eks:CreateCluster"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}