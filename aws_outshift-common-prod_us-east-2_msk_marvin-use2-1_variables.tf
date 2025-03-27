variable "kafka_version" {
  description = "Kafka version to deploy"
  type        = string
  default     = "2.8.1"
}

variable "instance_type" {
  description = "Instance type to use for Kafka brokers"
  type        = string
  default     = "kafka.m5.large"
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
    "producer" = {
      description = "Auth credentials for marvin-prod-use2-1-msk"
      vault_path  = "secret/prod/marvin/msk-marvin-prod-use2/producer"
    },
  }
}
