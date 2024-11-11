resource "aws_cloudwatch_log_group" "test" {
  name = "test"

  tags = {
    Environment = "production"
    Application = "maxweather"
  }
}

# AWSLoadBalancerControllerIAMPolicy
data "aws_iam_policy_document" "cloudwatch_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      #check the service account name and copy it here
      values = ["system:serviceaccount:default:fluent-bit"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}
resource "aws_iam_role" "cloudwatch" {
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role_policy.json
  name               = "cloudwatch"
}

resource "aws_iam_policy" "cloudwatch" {
  name        = "cloudwatch"
  description = "Policy for the AWS Load Balancer Controller"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.cloudwatch.name
  policy_arn = aws_iam_policy.cloudwatch.arn
}

#resource "aws_eks_addon" "cloudwatch" {
#  cluster_name                = aws_eks_cluster.cluster.name
#  addon_name                  = "amazon-cloudwatch-observability"
#  depends_on = [aws_eks_cluster.cluster]
#}