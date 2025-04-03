terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/motific-staging/iam/enhanced-monitoring-iam-roles.tfstate"
    region = "us-east-2"
 }
}
