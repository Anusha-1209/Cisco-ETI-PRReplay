terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/aws/eticloud-scratch-c/us-east-2/rds/helloworld.tfstate"
    region = "us-east-2"
  }
}
