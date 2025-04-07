resource "aws_lambda_function" "github_webhook_lambda" {
  s3_bucket     = aws_s3_bucket.s3.bucket
  s3_key        = "github-webhook-lambda.zip"
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.8"

  environment {
    variables = {
      EVENT_BUS_NAME            = aws_sqs_queue.github_webhook_queue.name
      GITHUB_WEBHOOK_SECRET_ARN = aws_secretsmanager_secret.webhook_secrets_manager.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.github_webhook_log_group,
  ]
}

# IAM
resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_function_name}-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "AssumeRoleLambda"
    }
  ]
}
POLICY
}


resource "aws_iam_policy_attachment" "lambda_execution_policy_attachment" {
  name       = aws_iam_policy.lambda_execution_policy.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
  roles      = [aws_iam_role.lambda_role.name]
}

resource "aws_iam_policy" "lambda_execution_policy" {
  description = "lambda-execution-policy"
  name        = "lambda-execution-policy"
  policy      = jsonencode({
  "Statement": [
    {
      "Action": [
        "sqs:DeleteMessage",
        "sqs:GetQueueUrl",
        "sqs:ListDeadLetterSourceQueues",
        "sqs:ChangeMessageVisibility",
        "sqs:PurgeQueue",
        "sqs:ReceiveMessage",
        "sqs:DeleteQueue",
        "sqs:SendMessage",
        "sqs:GetQueueAttributes",
        "sqs:ListQueueTags",
        "sqs:CreateQueue",
        "sqs:SetQueueAttributes"
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
    },
    {
        "Sid": "VisualEditor2",
        "Action": "events:PutEvents",
        "Resource": "arn:aws:events:us-east-2:626007623524:event-bus/default",
        "Effect": "Allow"
    },
    {
        "Sid": "SecretsManager",
        "Action": [
            "secretsmanager:DescribeSecret",
            "secretsmanager:GetSecretValue"
        ],
        "Resource": aws_secretsmanager_secret.webhook_secrets_manager.arn,
        "Effect": "Allow"
    }

  ],
  "Version": "2012-10-17"
})
}
