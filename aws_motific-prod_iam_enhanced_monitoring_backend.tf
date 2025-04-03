terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws/motific-prod/iam/enhanced-monitoring-iam-roles.tfstate"
    region = "us-east-2"
 }
}