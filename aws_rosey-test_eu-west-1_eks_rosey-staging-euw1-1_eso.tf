module "eso_eticloud" {
  source               = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=matunger-patch-1"
  cluster_name         = "rosey-staging-euw1-1"
  environment          = "staging"
}