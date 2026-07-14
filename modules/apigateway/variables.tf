variable "apigateway_name" {
  type        = string
  description = "Name of the API Gateway"
}

variable "lambda_function_invoke_arn" {
  type        = string
  description = "Invoke ARN of the Lambda function"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention in days"
  default     = 30
}

variable "stage" {
  type        = string
  description = "Deployment stage (dev/prod)"
}
