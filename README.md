# acp-tf-lambda-ses-bounce-suppressor

This python based AWS lambda function aims to automate the suppression of bounced email addresses from the AWS SES service via an SQS trigger

## Example usage
```
module "ses_bounce_suppressor" {
  source = "git::https://github.com/UKHomeOffice/acp-tf-lambda-ses-bounce-suppressor?ref=v0.0.1"

  function_name      = "${var.ses_identity}-ses-bounce-suppressor"
  sqs_ses_bounce_arn = ""
  sqs_kms_arn        = ""
  
  tags = {
    TYPE        = var.environment
    ENVIRONMENT = "test"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.72.0 |

## Resources

| Name | Type |
|------|------|
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy_document.lambda_default_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy.lambda_default_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.lambda_default_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.lambda_sqs_kms_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy.lambda_sqs_kms_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.lambda_sqs_kms_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.lambda_dynamo_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy.lambda_dynamo_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.lambda_dynamo_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [archive_file.lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_lambda_function.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_event_source_mapping.lambda_sqs_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="function_name"></a> [function\_name](#input\_function\_name) | The name of the ses suppressor function | `string` | n/a | yes |
| <a name="dynamo_table_name"></a> [dynamo\_table\_name](#input\_dynamo\_table\_name) | The name of the dynamo table to store analytics in - leave blank to disable | `string` | null | no |
| <a name="dynamo_ttl_days"></a> [dynamo\_ttl\_days](#input\_dynamo\_ttl\_days) | The time in days to set the ttl on dynamo table entries | `number` | 14 | no |
| <a name="lambda_max_sqs_concurrency"></a> [lambda\_max\_sqs\_concurrency](#input\_lambda\_max\_sqs\_concurrency) | The maximum number of lambda invocations by the sqs queue at a given time | `number` | 2 | no |
| <a name="lambda_sqs_batch_size"></a> [lambda\_sqs\_batch\_size](#input\_lambda\_sqs_\batch\_size) | The maximum number of sqs messages that a single function invocation can process | `number` | 10 | no |
| <a name="ses_identity"></a> [ses\_identity](#input\_ses\_identity) | The name of the SES identity that the suppression is for | `string` | n/a | yes |
| <a name="sqs_kms_arn"></a> [sqs\_kms\_arn](#input\_sqs\_kms\_arn) | The ARN of the KMS key of the SQS queue used to trigger the lambda function if configured | `string` | null | no |
| <a name="sqs_ses_bounce_arn"></a> [sqs\_ses\_bounce\_arn](#input\_sqs\_ses\_bounce\_arn) | The ARN of the sqs that will be used to trigger the lambda function | `string` | n/a | yes |
| <a name="timeout"></a> [timeout](#input\_timeout) | The maximum allowed time for the lambda function to start in seconds | `number` | 30 | no |
| <a name="tags"></a> [tags](#input\_tags) | The tags to attach to AWS resources | `map` | null | no |
