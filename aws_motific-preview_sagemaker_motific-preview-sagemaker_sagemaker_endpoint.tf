resource "aws_sagemaker_model" "redaction-pii-preview-model" {
  name               = "redaction-pii-preview-model"
  execution_role_arn = aws_iam_role.motific-preview.arn

  primary_container {
    mode            = "SingleModel"
    image           = "763104351884.dkr.ecr.us-east-2.amazonaws.com/huggingface-pytorch-inference:1.10.2-transformers4.17.0-gpu-py38-cu113-ubuntu20.04"
    model_data_url  = "s3://motific-preview-sagemaker/models/redaction/v2/roberta-large-ner-english/model.tar.gz"
    environment     = {
      "HF_MODEL_ID" = "Jean-Baptiste/roberta-large-ner-english"
      "HF_TASK"     = "token-classification"
      "SAGEMAKER_CONTAINER_LOG_LEVEL" = "20"
      "SAGEMAKER_REGION" = "us-east-2"
    }
  }
}

resource "aws_sagemaker_endpoint_configuration" "ec" {
  name = "redaction-pii-preview-model-config"

  production_variants {
    variant_name           = "preview"
    model_name             = aws_sagemaker_model.redaction-pii-preview-model.name
    initial_instance_count = 1
    instance_type          = "ml.g4dn.xlarge"
  }
}

resource "aws_sagemaker_endpoint" "e" {
  name                 = "redaction-pii-preview-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.ec.name
}

