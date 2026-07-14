data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/app/lambda_function"
  output_path = "${path.module}/../../src/app/lambda-function.zip"
  excludes    = ["__pycache__", "venv", "tests"]
}

resource "aws_lambda_function" "this" {
  filename         = "${path.module}/../../src/app/lambda-function.zip"
  source_code_hash = filebase64sha256("${path.module}/../../src/app/lambda-function.zip")

  function_name = "${var.function_name}-${var.stage}-lambda"
  role          = var.lambda_iam_execution_role_arn
  handler       = "app.handler.handler"
  runtime       = "python3.13"
  memory_size   = 512
  timeout       = 30

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      STAGE                = var.stage
      POWERTOOLS_LOG_LEVEL = var.stage == "prod" ? "INFO" : "DEBUG"
      DB_HOST              = var.rds_endpoint
      DB_USER              = var.db_user
      DB_NAME              = var.db_name
      DB_PORT              = "3306"
      AWS_REGION_NAME      = var.region
    }
  }
}

resource "aws_lambda_permission" "central_apigw" {
  statement_id  = "AllowExecutionFromCentralAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.central_api_gateway_execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.function_name}-${var.stage}-lambda"
  retention_in_days = 14
}
