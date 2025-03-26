data "tls_certificate" "gh_actions" {
  url = local.gh_actions_oidc_provider_url
}
