resource "aws_iam_role" "lambda_iam_execution_role" {
  name = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_basic_exec_role_attachment" {
  name       = var.policy_name
  roles      = [aws_iam_role.lambda_iam_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_exec_role_attachment" {
  role       = aws_iam_role.lambda_iam_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "lambda_vpc_access_policy" {
  name        = "analytics-service-lambda-vpc-access-policy-${var.stage}"
  description = "Allows Lambda to manage network interfaces in VPC"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access_attachment" {
  policy_arn = aws_iam_policy.lambda_vpc_access_policy.arn
  role       = aws_iam_role.lambda_iam_execution_role.name
}

resource "aws_iam_policy" "lambda_rds_policy" {
  name        = "analytics-service-lambda-rds-access-policy-${var.stage}"
  description = "Allows Lambda to connect to RDS via IAM auth"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["rds:DescribeDBInstances", "rds:Connect"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_lambda_rds_policy" {
  role       = aws_iam_role.lambda_iam_execution_role.name
  policy_arn = aws_iam_policy.lambda_rds_policy.arn
}

resource "aws_iam_policy" "rds_iam_auth_policy" {
  name = "analytics-service-lambda-rds-iam-auth-policy-${var.stage}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["rds-db:connect"]
        Effect   = "Allow"
        Resource = [
          "arn:aws:rds-db:${var.region}:${var.account_id}:dbuser:${var.rds_resource_id}/${var.db_user}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_iam_auth_attach" {
  role       = aws_iam_role.lambda_iam_execution_role.name
  policy_arn = aws_iam_policy.rds_iam_auth_policy.arn
}

# IAM role so API Gateway can push logs to CloudWatch
resource "aws_iam_role" "apigateway_cloudwatch_role" {
  name = var.apigw_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_apigateway_logs_policy" {
  role       = aws_iam_role.apigateway_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = aws_iam_role.apigateway_cloudwatch_role.arn
}
