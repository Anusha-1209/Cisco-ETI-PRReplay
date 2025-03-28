# This file was created by Outshift Platform Self-Service automation.
terraform {
  backend "s3" {
    # We separate the different levels of development into different buckets.
    # The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod.
    # The environment should match the CSBEnvironment below.
    bucket = "eticloud-tf-state-nonprod"

    # note the path here. It should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    key = "terraform-state/apisec-dev/eu-west-1/eks/e2e.tfstate"

    # This is the region where the backend S3 bucket is located. SRE team default, Do not change.
    region = "us-east-2"
  }
}
