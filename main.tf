module "sns_topics" {
  source             = "github.com/paulo-tinoco/terraform-sns-module"
  topics             = var.topics
  default_fifo_topic = var.fifo
  default_tags       = var.default_tags
  resource_prefix    = var.resource_prefix
}

module "sqs_queues" {
  source             = "github.com/paulo-tinoco/terraform-sqs-module"
  queues             = var.queues
  default_fifo_queue = var.fifo
  default_tags       = var.default_tags
  resource_prefix    = var.resource_prefix
}

locals {
  arn_sns_prefix = "arn:aws:sns:${var.region}:${var.account_id}:"

  queues = flatten([
    for sqs_queue in var.queues : {
      name = var.resource_prefix != "" ? "${var.resource_prefix}__${sqs_queue.name}" : sqs_queue.name
      topics_to_subscribe = flatten([
        for topic in sqs_queue.topics_to_subscribe : [
          {
            name          = var.resource_prefix != "" ? "${var.resource_prefix}__${topic.name}" : topic.name
            filter_policy = topic.filter_policy != null ? topic.filter_policy : var.default_filter_policy
          }
        ]
      ])
    }
  ])

  sqs_queues = {
    for sqs_queue in local.queues : var.fifo ? "${sqs_queue.name}.fifo" : sqs_queue.name => sqs_queue
  }

  subscriptions = flatten([
    for sqs_index, sqs_queue in local.queues : [
      for subscribe in sqs_queue.topics_to_subscribe : {

        topic_name     = var.fifo ? "${subscribe.name}.fifo" : subscribe.name,
        topic_arn      = var.fifo ? "${local.arn_sns_prefix}${subscribe.name}.fifo" : "${local.arn_sns_prefix}${subscribe.name}",
        sqs_queue_name = var.fifo ? "${sqs_queue.name}.fifo" : sqs_queue.name,
        filter_policy  = subscribe.filter_policy
      }
    ]
  ])


  topics_subscriptions = {
    for topic in local.subscriptions : "${topic.sqs_queue_name}_${topic.topic_name}" => topic
  }
}

resource "aws_sns_topic_subscription" "sns_queues_subscriptions" {
  for_each = local.topics_subscriptions

  topic_arn     = each.value.topic_arn
  protocol      = "sqs"
  endpoint      = module.sqs_queues.queues[each.value.sqs_queue_name].arn
  filter_policy = jsonencode(each.value.filter_policy)
}
