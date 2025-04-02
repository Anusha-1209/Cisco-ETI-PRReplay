resource "aws_iam_role" "dragonfly" {
  name = "dragonfly"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::346196940956:saml-provider/cloudsso.cisco.com"
        },
        "Action" : "sts:AssumeRoleWithSAML",
        "Condition" : {
          "StringEquals" : {
            "SAML:aud" : "https://signin.aws.amazon.com/saml"
          }
        }
      }
    ]
  })

  tags = {
    Name = "dragonfly"
  }
}


resource "aws_iam_policy" "dragonfly-saml-policy" {
  name        = "dragonfly-saml-policy"
  path        = "/"
  description = "Dragonfly SSO IAM role access"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "ListQueues",
			"Effect": "Allow",
			"Action": "sqs:ListQueues",
			"Resource": "*"
		},
		{
			"Sid": "AccessLighspinQueue",
			"Effect": "Allow",
			"Action": "sqs:*",
			"Resource": "arn:aws:sqs:eu-west-1:346196940956:lightspin-sqs-dev-1-dev-2.fifo"
		},
		{
			"Sid": "ReadOnlyOpenSearch",
			"Effect": "Allow",
			"Action": [
				"es:Describe*",
				"es:List*",
				"es:Get*"
			],
			"Resource": "*"
		},
		{
			"Sid": "AccessOpenSearchDragonfly",
			"Effect": "Allow",
			"Action": "es:*",
			"Resource": "arn:aws:es:eu-west-1:346196940956:domain/dragonfly-dev-1-es"
		},
		{
			"Sid": "ReadOnlyKafka",
			"Action": [
				"kafka:Describe*",
				"kafka:List*",
				"kafka:Get*",
				"ec2:DescribeNetworkInterfaces",
				"ec2:DescribeSecurityGroups",
				"ec2:DescribeSubnets",
				"ec2:DescribeVpcs",
				"kms:DescribeKey"
			],
			"Effect": "Allow",
			"Resource": "*"
		},
		{
			"Sid": "AccessDragonflyKafka",
			"Effect": "Allow",
			"Action": "kafka:*",
			"Resource": [
				"arn:aws:kafka:eu-west-1:346196940956:cluster/msk-dragonfly-dev-1/1e4fadf5-4d2f-406f-8725-1f3c02322bc5-4",
				"arn:aws:kafka:eu-west-1:346196940956:cluster/dragonfly-poc-1/5ec8fbfd-6fcc-4c53-8655-8ca1bdf5b843-4"
			]
		},
		{
			"Sid": "ReadOnlyLambda",
			"Effect": "Allow",
			"Action": [
				"lambda:GetAccountSettings",
				"lambda:GetEventSourceMapping",
				"lambda:GetFunction",
				"lambda:GetFunctionConfiguration",
				"lambda:GetFunctionCodeSigningConfig",
				"lambda:GetFunctionConcurrency",
				"lambda:ListEventSourceMappings",
				"lambda:ListFunctions",
				"lambda:ListTags",
				"iam:ListRoles"
			],
			"Resource": "*"
		},
		{
			"Sid": "AccessDragonflyLambda",
			"Effect": "Allow",
			"NotAction": [
				"lambda:AddPermission",
				"lambda:PutFunctionConcurrency"
			],
			"Resource": "arn:aws:lambda:eu-west-1:346196940956:function:CNDRPipelineAuthorizer"
		},
		{
			"Sid": "ReadOnlyEC2",
			"Effect": "Allow",
			"Action": [
				"ec2:DescribeInstances",
				"ec2:DescribeImages",
				"ec2:DescribeTags",
				"ec2:DescribeSnapshots"
			],
			"Resource": "*"
		}
	]
}
EOF
}



###### SSO Access #######

resource "aws_iam_role_policy_attachment" "dragonfly-policy-attachment" {
  role       = aws_iam_role.dragonfly.name
  policy_arn = aws_iam_policy.dragonfly-saml-policy.arn
}
