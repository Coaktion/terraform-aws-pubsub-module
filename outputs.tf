output "sns_topic_subscriptions" {
  description = "A map of SNS topic subscriptions."
  value       = aws_sns_topic_subscription.sns_queues_subscriptions
}

output "queues" {
  description = "A map of SQS queues."
  value       = local.queues
}

output "local_sqs_queues" {
  description = "A map of SQS queues."
  value       = local.sqs_queues
}

output "local_subscriptions" {
  description = "A map of SNS topic subscriptions."
  value       = local.subscriptions
}

output "local_topics_subscriptions" {
  description = "A map of SNS topic subscriptions."
  value       = local.topics_subscriptions
}
