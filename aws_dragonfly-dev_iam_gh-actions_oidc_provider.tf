resource "aws_iam_openid_connect_provider" "default" {
  url = local.gh_actions_oidc_provider_url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    data.tls_certificate.gh_actions.certificates[0].sha1_fingerprint,
  ]
}
