# lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "lambda_dir_zip" {
  type        = "zip"
  output_path = "/tmp/lambda_dir_zip.zip"
  source_dir  = "./src"
}

resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.lambda_dir_zip.output_path
  source_code_hash = data.archive_file.lambda_dir_zip.output_base64sha256
  function_name    = "sns_to_discord"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "sns_to_discord.lambda_handler"

  runtime = "python3.9"

  environment {
    variables = {
      HOOK_URL = "https://discord.com/api/webhooks/1078119505953296535/cFKz9lRpRp4qbe4OC75TJJ4_8D6erDY9bxbhmfiD6OzNqvyvpHjlkgoyhGAAqBB175AN"
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda-log]
}

resource "aws_cloudwatch_log_group" "lambda-log" {
  name              = "/aws/lambda/sns_to_discord"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda-policy" {
  name        = "lambda-policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-policy-attch" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda-policy.arn
}

resource "aws_lambda_permission" "lambda-permission" {
  statement_id  = "AllowExecutionFromSNStopic"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.cloudwatch-alarm.arn
}

