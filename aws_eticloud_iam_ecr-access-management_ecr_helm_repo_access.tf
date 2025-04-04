module "ecr-access-common" {
  source = "./module/"
  oidcs = [
    {
      oidc-url = "https://oidc.eks.us-east-2.amazonaws.com/id/43DADA9FA93A358C59DB2A908D525B93" # Cluster scs-dev-1-vluster
      oidc-thumbprint = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
    },
    {
      oidc-url = "https://oidc.eks.us-east-2.amazonaws.com/id/F2888E32629E27230609661A826A0B46" # Cluster scs-dev-1
      oidc-thumbprint = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
    },
    {
      oidc-url = "https://oidc.eks.eu-north-1.amazonaws.com/id/272AF76A4B5D9449ADE492CF6013032A" # Cluster eks-gitops-cnapp-1
      oidc-thumbprint = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
    },
    {
      oidc-url = "https://oidc.eks.us-east-2.amazonaws.com/id/E33780C1A13F01E6C641F5CDB752F29D" # Cluster eks-gitops-genai-1
      oidc-thumbprint = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
    },
    {
      oidc-url = "https://oidc.eks.us-east-2.amazonaws.com/id/5212D47604AC8A5C7DE4CCD518C8E481" # Cluster eks-dev-gitops-1
      oidc-thumbprint = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
    },
  ]
  
}