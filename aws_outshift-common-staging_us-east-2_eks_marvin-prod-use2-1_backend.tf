terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-staging"
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/outshift-common-staging/us-east-2/eks/marvin-staging-use2-1.tfstate"
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2"
  }
}
