terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-sandbox"
    key            = "terraform-state/eticloud/iam/sre-audit-ro.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
