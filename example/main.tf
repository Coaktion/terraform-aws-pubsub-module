provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "name_service_example_sns_topics" {
  source = "../"

  account_id      = data.aws_caller_identity.current.account_id
  region          = data.aws_region.current.name # Opcional, padrão => "us-east-1"
  resource_prefix = "example"                    # Opcional

  fifo = true # Opcional, padrão => false

  topics = [
    {
      name = "example_topic"
      policy                      = ""    # Opcional
      filter_policy = { # Opcional, padrão => {}
        "eventType" = ["order_placed", "order_cancelled"]
      }
      content_based_deduplication = false # Opcional, padrão => false. Obrigatório ser "true" para tópicos fifo
    }
  ]

  queues = [
    {
      name                       = "example_queue"
      create_queue               = true              # Opcional, padrão => true
      service                    = "example_service" # Opcional
      delay_seconds              = 30                # Opcional
      max_message                = 10                # Opcional
      visibility_timeout_seconds = 60                # Opcional
      message_retention_seconds  = 1209600           # Opcional
      receive_wait_time_seconds  = 20                # Opcional
      max_receive_count          = 5                 # Opcional
      topics_to_subscribe = [
        {
          name       = "example_topic"
          use_prefix = false # Opcional, padrão => true

          # IMPORTANTE: Função redundante com a variável "topics", utilizar um ou outro.
          policy                      = ""   # Opcional
          filter_policy               = {}   # Opcional, padrão => {}
          content_based_deduplication = true # Opcional, padrão => false. Obrigatório ser "true" para tópicos fifo
          create_topic                = true # Opcional, padrão => false.
        },
        {
          name = "another_example_topic"

          # IMPORTANTE: Função redundante com a variável "topics", utilizar um ou outro.
          use_prefix                  = true  # Opcional, padrão => true
          policy                      = ""    # Opcional
          filter_policy               = {}    # Opcional, padrão => {}
          content_based_deduplication = false # Opcional, padrão => false. Obrigatório ser "true" para tópicos fifo
          create_topic                = true  # Opcional, padrão => false
        }
      ]
    }
  ]

  default_tags = { # Opcional, padrão => {}
    # chave = valor
    Environment = "dev"
    Project     = "example_project"
  }
}
