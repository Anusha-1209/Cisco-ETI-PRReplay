module "eks" {
  source = "../../../../../modules/eks"
  name   = var.name
  cidr   = "10.0.0.0/16"
}