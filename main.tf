resource "kubernetes_namespace" "aws_observability" {
  metadata {
    annotations = {
      name = "aws-observability"
    }
    labels = {
      aws-observability = "enabled"
    }
    name = "aws-observability"
  }
}

resource "kubernetes_config_map" "aws_logging" {
  metadata {
    name      = "aws-logging"
    namespace = "aws-observability"
  }

  data = {
    "output.conf" = templatefile(
      "${path.module}/output.conf.tpl",
      {
        region  = var.region
        project = var.project
      }
    )
    "parsers.conf" = file("${path.module}/parsers.conf")
  }
}

data "aws_iam_policy_document" "aws_fargate_logging_policy" {
  statement {
    sid = "1"

    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "aws_fargate_logging_policy" {
  name   = "aws_fargate_logging_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.aws_fargate_logging_policy.json
}

resource "aws_iam_role_policy_attachment" "aws_fargate_logging_policy_attach_role" {
  role       = var.fargate_role_name
  policy_arn = aws_iam_policy.aws_fargate_logging_policy.arn
}
