data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.root}/tmp/lambda_zip.zip"
  source_dir  = "${path.module}/lambda/"
}

resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  description      = "github.com/UKHomeOffice/acp-tf-lambda-ses-bounce-suppressor"
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  role             = aws_iam_role.lambda_role.arn
  function_name    = var.function_name
  handler          = "function.lambda_handler"
  runtime          = "python3.10"
  architectures    = ["arm64"]
  timeout          = var.timeout

  environment {
    variables = {
      DYNAMO_TABLE    = var.dynamo_table_name
      DYNAMO_TTL_DAYS = var.dynamo_ttl_days
      SES_IDENTITY    = var.ses_identity
    }
  }

  tags = var.tags
}

resource "aws_lambda_event_source_mapping" "lambda_sqs_trigger" {
  count            = var.sqs_ses_bounce_arn != "" ? 1 : 0
  enabled          = true
  function_name    = aws_lambda_function.lambda.arn
  event_source_arn = var.sqs_ses_bounce_arn
  batch_size       = var.lambda_sqs_batch_size

  # Supported on aws provider versions <= 4.51.0
  scaling_config {
    maximum_concurrency = var.lambda_max_sqs_concurrency
  }
}