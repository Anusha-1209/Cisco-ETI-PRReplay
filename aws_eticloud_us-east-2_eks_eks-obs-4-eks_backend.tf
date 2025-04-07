terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-eticloud/eks/us-east-2/eks-obs-4-eks.tfstate"
    region = "us-east-2"
  }
}
