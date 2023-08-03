module "sns_topics" {
  source          = "github.com/paulo-tinoco/terraform-sns-module"
  topics          = var.topics
  fifo_topic      = var.fifo
  default_tags    = var.default_tags
  resource_prefix = var.resource_prefix
}

module "sqs_queues" {
  source          = "github.com/paulo-tinoco/terraform-sqs-module"
  queues          = var.queues
  fifo_queue      = var.fifo
  default_tags    = var.default_tags
  resource_prefix = var.resource_prefix
}


locals {
  subscriptions = flatten([
    for sqs_index, sqs_queue in var.queues : [
      for topic in sqs_queue.topics_to_subscribe : {
        topic_name     = topic.name,
        sqs_queue_name = sqs_queue.name,
        topic_arn      = "arn:aws:sns:${var.region}:${var.account_id}:${topic.name}",
        queue_arn      = "arn:aws:sqs:${var.region}:${var.account_id}:${sqs_queue.name}",
      }
    ]
  ])

  topics_subscriptions = {
    for topic in local.subscriptions : "${topic.sqs_queue_name}_${topic.topic_name}" => topic
  }
}

resource "aws_sns_topic_subscription" "sns_queues_subscriptions" {
  for_each = local.topics_subscriptions

  topic_arn     = var.fifo ? "${each.value.topic_arn}.fifo" : each.value.topic_arn
  protocol      = "sqs"
  endpoint      = var.fifo ? "${each.value.queue_arn}.fifo" : each.value.queue_arn
  filter_policy = jsonencode(var.filter_policy)

  depends_on = [module.sns_topics, module.sqs_queues]
}
