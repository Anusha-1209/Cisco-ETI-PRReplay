output "zookeeper_connect_string" {
  value = aws_msk_cluster.dragonfly_msk_1.zookeeper_connect_string
}

output "bootstrap_brokers" {
  value = aws_msk_cluster.dragonfly_msk_1.bootstrap_brokers
}

output "bootstrap_brokers_tls" {
  value = aws_msk_cluster.dragonfly_msk_1.bootstrap_brokers_tls
}
