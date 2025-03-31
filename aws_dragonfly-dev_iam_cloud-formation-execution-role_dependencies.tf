data aws_caller_identity current {}
data aws_region current {}

data "aws_vpc" "eks_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dragonfly-dev-2-vpc"]
  }
}

data "aws_subnets" "eks_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.eks_vpc.id]
  }
  tags = {
    Tier = "Private"
  }
}
