terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-eticloud/vpc/us-east-2/eks-obs-4-vpc.tfstate"
    region = "us-east-2"
  }
}
