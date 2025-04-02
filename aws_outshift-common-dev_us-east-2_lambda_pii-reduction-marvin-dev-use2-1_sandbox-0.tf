module "lambda_function_container_image" {
  source = "terraform-aws-modules/lambda/aws"
  function_name = "pii-reduction-marvin-dev-sandbox-0-use2-1"
  description   = "Marvin Pii reduction"
  create_package = false
  timeout = 180
  memory_size = 3008
  image_uri    = "626007623524.dkr.ecr.us-east-2.amazonaws.com/marvin/images/pii-service/server:2024-07-18-f563642"
  package_type = "Image"
  attach_policy_statements = true
  policy_statements = {
    sqs = {
      effect    = "Allow",
      actions   = [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:getQueueattributes"
      ]
      resources = ["arn:aws:sqs:*:${local.account_id}:*"]
    }
    ecr = {
      effect: "Allow",
      actions: [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      resources: ["arn:aws:ecr:us-east-2:626007623524:repository/marvin/images/pii-service/server"]
    }
  }
  environment_variables = {
    SQS_URL = "https://sqs.us-east-2.amazonaws.com/471112537430/marvin-collect-events-dev-sandbox-0-use2-1"
  }
}
