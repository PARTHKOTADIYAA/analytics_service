output "api_endpoint" {
  description = "Base URL of the analytics events endpoint"
  value       = "${module.apigateway.api_endpoint}/events"
}

output "lambda_function_name" {
  value = module.lambda.function_name
}
