# Terraform SNS Topic Subscription Module

Módulo Terraform para criar tópicos SNS e filas SQS com inscrição automática.

## Usage

```hcl
module "pubsub" {
  source = "github.com/Coaktion/terraform-aws-pubsub-module"

  topics = [
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
        }
      ]
    }
  ]

  fifo       = true
  account_id = "000000000000"
}
```
