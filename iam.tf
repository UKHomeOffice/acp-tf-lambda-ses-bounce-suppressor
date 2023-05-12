data "aws_iam_policy_document" "lambda_role_policy" {
  statement {
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_role_policy.json

  tags = var.tags
}

# Default minimal lambda role
data "aws_iam_policy_document" "lambda_default_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.function_name}:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage"
    ]
    resources = [
      var.sqs_ses_bounce_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ses:PutSuppressedDestination",
      "ses:GetSuppressedDestination"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "lambda_default_permissions" {
  name        = "${var.function_name}-lambda-default-policy"
  description = "Default permissions for ${var.function_name}"
  policy      = data.aws_iam_policy_document.lambda_default_permissions.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_default_permissions" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_default_permissions.arn
}

# KMS permissions if specified
data "aws_iam_policy_document" "lambda_sqs_kms_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      var.sqs_kms_arn
    ]
  }
}

resource "aws_iam_policy" "lambda_sqs_kms_permissions" {
  count       = var.sqs_kms_arn != "" ? 1 : 0
  name        = "${var.function_name}-lambda-sqs-kms-role-policy"
  description = "Additional SQS KMS permissions for ${var.function_name}"
  policy      = data.aws_iam_policy_document.lambda_sqs_kms_permissions.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_kms_permissions" {
  count      = var.sqs_kms_arn != "" ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sqs_kms_permissions[0].arn
}

# Dynamo table permissions if speicified
data "aws_iam_policy_document" "lambda_dynamo_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.dynamo_table_name}"
    ]
  }
}

resource "aws_iam_policy" "lambda_dynamo_permissions" {
  count       = var.dynamo_table_name != "" ? 1 : 0
  name        = "${var.function_name}-lambda-dynamo-role-policy"
  description = "Additional dynamo table permissions for ${var.function_name}"
  policy      = data.aws_iam_policy_document.lambda_dynamo_permissions.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_dynamo_permissions" {
  count      = var.dynamo_table_name != "" ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamo_permissions[0].arn
}


# Dynamo Table KMS permissions if required
data "aws_iam_policy_document" "lambda_dynamo_kms_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      var.dynamo_kms_arn
    ]
  }
}

resource "aws_iam_policy" "lambda_dynamo_kms_permissions" {
  count       = var.dynamo_kms_arn != "" ? 1 : 0
  name        = "${var.function_name}-lambda-dynamo-kms-role-policy"
  description = "Additional Dynamo KMS permissions for ${var.function_name}"
  policy      = data.aws_iam_policy_document.lambda_dynamo_kms_permissions.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_dynamo_kms_permissions" {
  count      = var.dynamo_kms_arn != "" ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamo_kms_permissions[0].arn
}
