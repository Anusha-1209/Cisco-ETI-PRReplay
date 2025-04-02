variable "kafka_version" {
  description = "Kafka version to deploy"
  type        = string
  default     = "3.6.0"
}

variable "instance_type" {
  description = "Instance type to use for Kafka brokers"
  type        = string
  default     = "kafka.m5.xlarge"
}

variable "number_of_broker_nodes" {
  description = "Number of Kafka broker nodes to deploy"
  type        = number
  default     = 3
}

variable "kafka_clients" {
  description = "Kafka clients to create"
  type = map(object({
    description = string
    vault_path  = string
  }))
  default = {
    "otel-collector" = {
      description = "Auth credentials of otel-collector for dragonfly-msk-prod-1"
      vault_path  = "secret/prod/msk/dragonfly-msk-1/kafka-clients/otel-collector"
    },
    "notification-service" = {
      description = "Auth credentials of notification-service for dragonfly-msk-prod-1"
      vault_path  = "secret/prod/msk/dragonfly-msk-1/kafka-clients/notification-service"
    },
    "opensearch-ingestion-service" = {
      description = "Auth credentials of ingestion-service for dragonfly-msk-prod-1"
      vault_path  = "secret/prod/msk/dragonfly-msk-1/kafka-clients/opensearch-ingestion-service"
    },
  }
}
