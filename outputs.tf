output "sns_topic_subscriptions" {
  description = "A map of SNS topic subscriptions."
  value       = aws_sns_topic_subscription.sns_queues_subscriptions
}
