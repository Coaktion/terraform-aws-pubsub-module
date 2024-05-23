locals {
  arn_sns_prefix = "arn:aws:sns:${var.region}:${var.account_id}:"

  queues_prefix = {
    for queue in var.queues : queue.name => {
      prefix = queue.service != null ? queue.service : var.resource_prefix
    }
  }

  queues = flatten([
    for sqs_queue in var.queues : {
      name                       = local.queues_prefix[sqs_queue.name].prefix != "" ? "${local.queues_prefix[sqs_queue.name].prefix}__${sqs_queue.name}" : sqs_queue.name
      create_queue               = sqs_queue.create_queue
      delay_seconds              = sqs_queue.delay_seconds
      max_message                = sqs_queue.max_message
      visibility_timeout_seconds = sqs_queue.visibility_timeout_seconds
      message_retention_seconds  = sqs_queue.message_retention_seconds
      receive_wait_time_seconds  = sqs_queue.receive_wait_time_seconds
      max_receive_count          = sqs_queue.max_receive_count
      topics_to_subscribe = flatten([
        for topic in sqs_queue.topics_to_subscribe : [
          {
            name                        = local.queues_prefix[sqs_queue.name].prefix != "" && topic.use_prefix ? "${local.queues_prefix[sqs_queue.name].prefix}__${topic.name}" : topic.name
            filter_policy               = topic.filter_policy != null ? topic.filter_policy : var.default_filter_policy
            content_based_deduplication = var.fifo ? true : topic.content_based_deduplication
            create_topic                = topic.create_topic
          }
        ]
      ])
    }
  ])

  topics = flatten([
    for queue in local.queues : [
      for topic in queue.topics_to_subscribe : topic if topic.create_topic == true
    ]
  ])

  queues_to_create = [
    for queue in local.queues : queue if queue.create_queue == true
  ]

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

data "aws_sqs_queue" "queues" {
  for_each = local.sqs_queues

  name = each.key

  depends_on = [
    module.sqs_queues,
  ]
}

module "sns_topics" {
  source             = "github.com/Coaktion/terraform-aws-sns-module"
  topics             = local.topics
  default_fifo_topic = var.fifo
  default_tags       = var.default_tags
}

module "sqs_queues" {
  source             = "github.com/Coaktion/terraform-aws-sqs-module"
  queues             = local.queues_to_create
  default_fifo_queue = var.fifo
  default_tags       = var.default_tags
}
resource "aws_sns_topic_subscription" "sns_queues_subscriptions" {
  for_each = local.topics_subscriptions

  topic_arn     = each.value.topic_arn
  protocol      = "sqs"
  endpoint      = data.aws_sqs_queue.queues[each.value.sqs_queue_name].arn
  filter_policy = jsonencode(each.value.filter_policy)
}
