terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-nonprod"
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/outshift-common-dev/us-east-2/msk/marvin-dev-use2-1.tfstate"
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2"
  }
}

