terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-sandbox"
    key    = "terraform-state/aws/dragonfly-dev/s3/dragonfly-kafka-connector-log-files.tfstate"
    region = "us-east-2"
  }
}
