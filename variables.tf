variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "default_filter_policy" {
  description = "The default filter policy to apply to subscriptions. This is a map of attribute name/value pairs. The default is an empty map, which matches all messages."
  type        = map(list(string))
  default     = {}
}

variable "queues" {
  description = "A list of maps describing the queues to create. Each map must contain a name key. The following keys are optional: delay_seconds, max_message, message_retention_seconds, receive_wait_time_seconds, max_receive_count, topics_to_subscribe."
  type = list(object({
    name         = string
    create_queue = optional(bool, true)
    topics_to_subscribe = list(object({
      name          = string
      filter_policy = optional(map(list(string)))
    }))
  }))
  default = []
}

variable "topics" {
  description = "A list of maps describing the topics to create. Each map must contain a name key. The following keys are optional: display_name, kms_master_key_id, policy, delivery_policy, sqs_success_feedback_sample_rate, sqs_failure_feedback_sample_rate, sqs_max_message_size, sqs_message_retention_seconds, sqs_receive_wait_time_seconds, sqs_visibility_timeout_seconds, sqs_delay_seconds, fifo_topic, content_based_deduplication, application_success_feedback_sample_rate, application_failure_feedback_sample_rate, application_max_message_size, application_message_retention_seconds, application_delivery_policy, application_receive_wait_time_seconds, application_visibility_timeout_seconds, application_delay_seconds, application_success_feedback_role_arn, application_failure_feedback_role_arn, application_success_feedback_target_arn, application_failure_feedback_target_arn, topics_to_subscribe."
  type = list(object({
    name                        = string
    content_based_deduplication = optional(bool, false)
  }))
  default = []
}

variable "default_tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
  default     = {}
}

variable "resource_prefix" {
  description = "A prefix to add to all resource names."
  type        = string
  default     = ""
}

variable "fifo" {
  description = "Boolean designating a FIFO topic and queue. If not set, it defaults to false making it standard."
  type        = bool
  default     = false
}
