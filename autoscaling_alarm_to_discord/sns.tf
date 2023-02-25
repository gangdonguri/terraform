# sns
resource "aws_sns_topic" "cloudwatch-alarm" {
  name = "cloudwatch-ararm-topic"
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.account_id,
      ]
    }
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_sns_topic.cloudwatch-alarm.arn,
    ]
    sid = "__default_statement_ID"
  }
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.cloudwatch-alarm.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

resource "aws_sns_topic_subscription" "lambda_target" {
  topic_arn = aws_sns_topic.cloudwatch-alarm.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda.arn
}
