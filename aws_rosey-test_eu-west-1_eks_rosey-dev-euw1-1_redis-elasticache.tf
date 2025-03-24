resource "aws_elasticache_replication_group" "rosey-dev-euw1-1" {
  replication_group_id       = "rosey-dev-euw1-1"
  description                = "Redis cluster for rosey-dev-euw1-1 ElastiCache"
  node_type                  = "cache.t2.medium"
  port                       = 6379
  parameter_group_name       = "default.redis3.2.cluster.on"
  automatic_failover_enabled = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  num_node_groups         = 2
  replicas_per_node_group = 1
}