# Terraform SNS Topic Subscription Module

Terraform module which creates SNS Topic Subscription resources on AWS.

## Usage

```hcl
module "sns_topic_subscription" {
  source = "github.com/paulo-tinoco/terraform-sns-topic-subscription-module"

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
