terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/keeper/eticloud/outshift-users/secrets-engines/aws/aws-eticloud.tfstate"
    region = "us-east-2"
  }
}
