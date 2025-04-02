terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-prod"
    key            = "terraform-state/aws/lightspin-prod/us-east-2/rds/rds.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
