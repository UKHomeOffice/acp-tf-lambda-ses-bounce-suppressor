variable "function_name" {
  description = "The name of the ses suppressor function"
}

variable "dynamo_table_name" {
  description = "The name of the dynamo table to store analytics in - leave blank to disable"
  default     = ""
}

variable "dynamo_kms_arn" {
  description = "The arn of the KMS key configured for the dynamo table if applicable"
  default     = ""
}

variable "dynamo_kms_arn_bool" {
  description = "Workaround for Terraform Count compute - this is for the optional dynamo_kms_arn variable and must be set if used"
  default     = false
}

variable "dynamo_ttl_days" {
  description = "The time in days to set the ttl on dynamo table entries - default is 14 days"
  default     = 14
}

# Supported on aws provider versions <= 4.51.0
variable "lambda_max_sqs_concurrency" {
  description = "The maximum number of lambda invocations by the sqs queue at a given time"
  default     = 2
}

variable "lambda_sqs_batch_size" {
  description = "The maximum number of sqs messages that a single function invocation can process"
  default     = 10
}

variable "ses_identity" {
  description = "The name of the SES identity that the suppression is for"
}

variable "sqs_kms_arn" {
  description = "The ARN of the KMS key of the SQS queue used to trigger the lambda function if configured"
  default     = ""
}

variable "sqs_kms_arn_bool" {
  description = "Workaround for Terraform Count compute (kms) - this is for the optional variable and must be set if used"
  default     = false
}

variable "sqs_ses_bounce_arn" {
  description = "The ARN of the sqs that will be used to trigger the lambda function"
  default     = ""
}

variable "timeout" {
  description = "The maximum allowed time for the lambda function to start in seconds"
  default     = 30
}

variable "tags" {
  description = "AWS resource tagging"
}
