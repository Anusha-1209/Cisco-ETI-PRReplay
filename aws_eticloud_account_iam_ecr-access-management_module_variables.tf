variable "oidcs" {
  type = list(map(string))
  default = [
    {
      oidc-url = "value1" # EKS cluster oidc url
      oidc-thumbprint = "value2" # EKS cluster OIDC thumbprint (possible to check on IAM service)
    }
  ]
}