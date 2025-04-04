data "aws_caller_identity" "current" {}
locals {
    account_id = data.aws_caller_identity.current.account_id
}


resource "aws_iam_openid_connect_provider" "oidc_issuer" {
  for_each = { for idx, map_data in var.oidcs : idx => map_data }
  url             = each.value["oidc-url"]
  thumbprint_list = [each.value["oidc-thumbprint"]]
  client_id_list  = ["sts.amazonaws.com"]
}



data "aws_iam_policy_document" "irsa" {
  # count = length(aws_iam_openid_connect_provider.oidc_issuer)
  statement {
    sid = "UniqueSidOne"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        for i in range(length(aws_iam_openid_connect_provider.oidc_issuer)) : aws_iam_openid_connect_provider.oidc_issuer[i].arn 
      ]
    }
  }
  statement {
    sid = "UniqueSidTwo"
    actions = [ "sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [
        # "arn:aws:sts::${local.account_id}:root" # Uncomment it and comment next line only at the first time role creation, bug of terraform and aws when you try to assume role that was created on the same run
        "arn:aws:sts::${local.account_id}:assumed-role/ecr-access-from-eks-common/external-secrets-provider-aws"
      ]
    }
  }
}

 
resource "aws_iam_role" "argocd_role" {
  name               =  "ecr-access-from-eks-common"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.irsa.json
}
 
resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.argocd_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}