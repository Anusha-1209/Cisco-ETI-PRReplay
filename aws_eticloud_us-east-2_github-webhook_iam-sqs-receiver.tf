resource "aws_iam_user" "github-webhook-sqs-receiver" {
  name = "github-webhook-sqs-receiver"
}

resource "aws_iam_access_key" "github-webhook-sqs-receiver_access_key" {
  user = aws_iam_user.github-webhook-sqs-receiver.name
}

resource "aws_iam_policy_attachment" "iam_policy_attachment" {
  name       = aws_iam_policy.github-webhook-sqs-receiver-policy.name
  policy_arn = aws_iam_policy.github-webhook-sqs-receiver-policy.arn
  users      = [aws_iam_user.github-webhook-sqs-receiver.name]
}

resource "vault_generic_secret" "access_keys" {
  path      = "secret/projects/github-webhook/receiver/prod/aws"
  provider  = vault.eticloud
  data_json = jsonencode({
    AWS_ACCESS_KEY_ID = aws_iam_access_key.github-webhook-sqs-receiver_access_key.id
    AWS_DEFAULT_REGION = "us-east-2"
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.github-webhook-sqs-receiver_access_key.secret
  })
}

resource "aws_iam_policy" "github-webhook-sqs-receiver-policy" {
  description = "github-webhook-sqs-receiver-policy"
  name        = "github-webhook-sqs-receiver-policy"
  policy      = jsonencode({
  "Statement": [
    {
      "Action": [
        "sqs:DeleteMessage",
        "sqs:GetQueueUrl",
        "sqs:ListDeadLetterSourceQueues",
        "sqs:ReceiveMessage",
        "sqs:GetQueueAttributes",
        "sqs:ListQueueTags"
      ],
      "Effect": "Allow",
      "Resource": aws_sqs_queue.github_webhook_queue.arn,
      "Sid": "VisualEditor0"
    },
    {
      "Action": "sqs:ListQueues",
      "Effect": "Allow",
      "Resource": "*",
      "Sid": "VisualEditor1"
    }
  ],
  "Version": "2012-10-17"
})
}
