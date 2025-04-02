terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/keeper/eticloud/apps/ospo/motific-outshift-users-namespace.tfstate"
    region = "us-east-2"
  }
}
