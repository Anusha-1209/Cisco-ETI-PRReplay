# OS endpoint
output "opensearch_endpoint" {
  value = aws_opensearch_domain.dragonfly_staging_1_os.endpoint
}

# OS dashboard endpoint
output "opensearch_dashboard_endpoint" {
  value = aws_opensearch_domain.dragonfly_staging_1_os.dashboard_endpoint
}
