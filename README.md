# Terraform SNS Topic Subscription Module

Módulo Terraform para criar tópicos SNS e filas SQS com inscrição automática.

## Usage

```hcl
module "pubsub" {
  source = "github.com/Coaktion/terraform-aws-pubsub-module"

  topics = [ # Will always create a topic
    {
      name = "validation_topic"
    }
  ]

  queues = [
    {
      name = "validation_queue"
      topics_to_subscribe = [
        {
          name = "validation_topic"
        },
        {
          name = "re_validation_topic"
          # You can choose create the topic here or in the "topics" variable
          create_topic = true # Optional, default is false.
        }
      ]
    }
  ]

  fifo       = true # Optional, default is false.
  account_id = "000000000000"
}
```
