terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-nonprod"
    key            = "terraform-state/aws-eticloud-preprod/iam/argocd-dev-backup-s3.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
