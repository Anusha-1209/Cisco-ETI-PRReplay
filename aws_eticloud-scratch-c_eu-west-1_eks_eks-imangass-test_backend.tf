terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket          = "eticloud-tf-state-nonprod"                                                       # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key             = "terraform-state/aws/eticloud-scratch-c/eu-west-1/eks/eks-imangass-test.tfstate"  # UPDATE ME.
    # This is the region where the backend S3 bucket is located.
    region          = "us-east-2"                                                                       # DO NOT CHANGE.

  }
}