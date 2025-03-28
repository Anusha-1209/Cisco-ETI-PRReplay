terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-sandbox"
    key    = "terraform-state/aws/dragonfly-staging/s3/dragonfly-kafka-connector-log-files.tfstate"
    region = "us-east-2"
  }
}
