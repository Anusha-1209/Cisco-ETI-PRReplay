# Create the IAM user secret engine will use to auth against AWS
resource "aws_iam_user" "vault-secret-engine-user-eticloud-scratch" {
  name     = "vault-secret-engine-user-eticloud-scratch"
  provider = aws.scratch
}

resource "aws_iam_access_key" "vault-secret-engine-user-eticloud-scratch" {
  user     = aws_iam_user.vault-secret-engine-user-eticloud-scratch.name
  provider = aws.scratch
}

resource "aws_iam_user_policy" "vault-secret-engine-user-eticloud-scratch" {
  name     = "vault-secret-engine-user-eticloud-scratch"
  user     = aws_iam_user.vault-secret-engine-user-eticloud-scratch.name
  provider = aws.scratch
  policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "${aws_iam_role.ci-default-role.arn}",
        "arn:aws:iam::380642323071:role/gbear"
      ]
    }
  ]
}
EOF
  
}


## greatbear ci role and policy

resource "aws_iam_role" "eticloud-scratch-greatbear-ci-role" {
  name               = "eticloud-scratch-greatbear-ci"
  provider           = aws.scratch
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${aws_iam_user.vault-secret-engine-user-eticloud-scratch.arn}"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = "eticloud-scratch-greatbear-ci-role"
  }
}

resource "aws_iam_role" "ci-default-role" {
  provider           = aws.scratch
  name               = "ci-default"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::380642323071:user/vault-secret-engine-user-eticloud-scratch"
        },
        "Action" : "sts:AssumeRole"
      },
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::380642323071:root"
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

resource "aws_iam_role_policy_attachment" "eticloud-scratch-ci-policy-attach" {
  provider   = aws.scratch
  role       = aws_iam_role.eticloud-scratch-greatbear-ci-role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
