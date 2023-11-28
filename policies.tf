resource "aws_sqs_queue_policy" "policy" {
  for_each = local.sqs_queues

  queue_url = data.aws_sqs_queue.queues[each.key].id

  policy = data.aws_iam_policy_document.queue_policy[each.key].json

  depends_on = [
    module.sqs_queues,
  ]
}

data "aws_iam_policy_document" "queue_policy" {
  for_each = local.sqs_queues

  dynamic "statement" {
    for_each = local.sqs_queues[each.key].topics_to_subscribe

    content {
      effect  = "Allow"
      actions = ["sqs:SendMessage"]

      principals {
        type        = "*"
        identifiers = ["*"]
      }

      resources = [
        data.aws_sqs_queue.queues[each.key].arn,
      ]

      condition {
        test     = "ArnEquals"
        variable = "aws:SourceArn"

        values = [
          local.topics_subscriptions[var.fifo ? "${each.key}_${statement.value.name}.fifo" : "${each.key}_${statement.value.name}"].topic_arn,
        ]
      }
    }
  }
}
