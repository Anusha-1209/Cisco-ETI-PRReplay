output "zookeeper_connect_string" {
  value = aws_msk_cluster.marvin-staging-1-msk.zookeeper_connect_string
}

output "bootstrap_brokers" {
  value = aws_msk_cluster.marvin-staging-1-msk.bootstrap_brokers
}

output "bootstrap_brokers_tls" {
  value = aws_msk_cluster.marvin-staging-1-msk.bootstrap_brokers_tls
}
