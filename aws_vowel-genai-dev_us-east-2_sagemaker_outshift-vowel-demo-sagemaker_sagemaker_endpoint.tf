resource "aws_sagemaker_model" "redaction-pii-demo-model" {
  name               = "redaction-pii-demo-model"
  execution_role_arn = aws_iam_role.redaction-pii-demo-role.arn

  primary_container {
    mode            = "SingleModel"
    model_data_url  = "s3://vowel-dev-sagemaker/models/redaction/v2/roberta-large-ner-english/model.tar.gz"
  }
}

resource "aws_iam_role" "redaction-pii-demo-role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}



resource "aws_sagemaker_endpoint_configuration" "ec" {
  name = "redaction-pii-demo-model-config"

  production_variants {
    variant_name           = "demo"
    model_name             = aws_sagemaker_model.redaction-pii-demo-model.name
    initial_instance_count = 1
    instance_type          = "ml.g4dn.xlarge"
  }
}

resource "aws_sagemaker_endpoint" "e" {
  name                 = "redaction-pii-demo-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.ec.name
}

