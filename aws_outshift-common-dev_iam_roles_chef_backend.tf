terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-nonprod"
    key            = "terraform-state/outshift-common-dev/iam/role/chef-eval-S3-admin.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
