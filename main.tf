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
      name                = var.resource_prefix != "" ? "${var.resource_prefix}${sqs_queue.name}" : sqs_queue.name
      topics_to_subscribe = sqs_queue.topics_to_subscribe
    }
  ])

  sqs_queues = {
    for sqs_queue in local.queues : var.fifo ? "${sqs_queue.name}.fifo" : sqs_queue.name => sqs_queue
  }

  subscriptions = flatten([
    for sqs_index, sqs_queue in local.queues : [
      for topic in sqs_queue.topics_to_subscribe : {
        topic_name     = var.fifo ? "${topic.name}.fifo" : topic.name,
        topic_arn      = var.fifo ? "${local.arn_sns_prefix}${topic.name}.fifo" : "${local.arn_sns_prefix}${topic.name}",
        sqs_queue_name = var.fifo ? "${sqs_queue.name}.fifo" : sqs_queue.name,
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
  filter_policy = jsonencode({ "region" : ["br"] })
}
