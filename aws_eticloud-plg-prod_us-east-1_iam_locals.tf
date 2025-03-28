locals {
  aws_account_id = data.aws_caller_identity.current.account_id

  cnapp_clusters = {
    cnapp-prod-eu = {
      eks_oidc = "oidc.eks.us-east-2.amazonaws.com/id/28A49D0DC19E0AE06F2E38C0AD473F7D"
    }
    cnapp-prod-us = {
      eks_oidc = "oidc.eks.us-east-2.amazonaws.com/id/EFF9B51923E64F3067C820180603F855"
    }
  }
}
