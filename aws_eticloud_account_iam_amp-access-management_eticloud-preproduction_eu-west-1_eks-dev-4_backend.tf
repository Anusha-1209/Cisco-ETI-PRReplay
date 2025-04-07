# terraform {
#   backend "s3" {
#     bucket = "eticloud-tf-state-prod"
#     key    = "terraform-state/aws-eticloud/iam/amp-access-management-eks-dev-3.tfstate"
#     region = "us-east-2"
#   }
# }

terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}
