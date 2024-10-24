# EventBridge Rule for Amplify notifications

resource "aws_cloudwatch_event_rule" "amplify_app_master" {
  name        = "amplify-${aws_amplify_app.pokedex.id}-${aws_amplify_branch.prod.branch_name}-branch-notification"
  description = "AWS Amplify build notifications for :  App: ${aws_amplify_app.pokedex.id} Branch: ${aws_amplify_branch.prod.branch_name}"

  event_pattern = jsonencode({
    "detail" = {
      "appId" = [
        aws_amplify_app.pokedex.id
      ]
      "branchName" = [
        aws_amplify_branch.prod.branch_name
      ],
      "jobStatus" = [
        "SUCCEED",
        "FAILED",
        "STARTED"
      ]
    }
    "detail-type" = [
      "Amplify Deployment Status Change"
    ]
    "source" = [
      "aws.amplify"
    ]
  })
}

resource "aws_cloudwatch_event_target" "amplify_app_master" {
  rule      = aws_cloudwatch_event_rule.amplify_app_master.name
  target_id = aws_amplify_branch.prod.branch_name
  arn       = aws_sns_topic.amplify_app_master.arn

  input_transformer {
    input_paths = {
      jobId  = "$.detail.jobId"
      appId  = "$.detail.appId"
      region = "$.region"
      branch = "$.detail.branchName"
      status = "$.detail.jobStatus"
    }

    input_template = var.input_template
  }
}

# SNS Topic for Amplify notifications

resource "aws_sns_topic" "amplify_app_master" {
  name = "amplify-${aws_amplify_app.pokedex.id}_${aws_amplify_branch.prod.branch_name}"
}

data "aws_iam_policy_document" "amplify_app_master" {
  statement {
    sid = "Allow_Publish_Events ${aws_amplify_branch.prod.arn}"

    effect = "Allow"

    actions = [
      "SNS:Publish",
    ]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }

    resources = [
      aws_sns_topic.amplify_app_master.arn,
    ]
  }
}

resource "aws_sns_topic_policy" "amplify_app_master" {
  arn    = aws_sns_topic.amplify_app_master.arn
  policy = data.aws_iam_policy_document.amplify_app_master.json
}

resource "aws_sns_topic_subscription" "email_subscriptions" {
  #topic_arn = aws_sns_topic.amplify_app_master.arn
  #protocol  = "email"
  #endpoint  = var.notification_email

  count     = length(var.email_addresses)
  topic_arn = aws_sns_topic.amplify_app_master.arn
  protocol  = "email"
  endpoint  = var.email_addresses[count.index] # Accede a cada correo en la lista
}