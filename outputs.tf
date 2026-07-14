output "api_gateway_invoke_url" {
  description = "Base URL of the analytics API"
  value       = module.apigateway.api_gateway_invoke_url
}

output "lambda_function_name" {
  value = module.lambda.function_name
}
