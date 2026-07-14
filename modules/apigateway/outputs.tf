output "api_gateway_id" {
  value       = aws_api_gateway_rest_api.analytics-service-api.id
  description = "ID of the analytics service API Gateway"
}

output "api_gateway_invoke_url" {
  value       = aws_api_gateway_stage.api_stage.invoke_url
  description = "Invoke URL for the analytics service API Gateway"
}

output "events_resource_id" {
  value       = aws_api_gateway_resource.events_resource.id
  description = "ID of /events resource"
}

output "health_resource_id" {
  value       = aws_api_gateway_resource.health_resource.id
  description = "ID of /health resource"
}

output "docs_resource_id" {
  value       = aws_api_gateway_resource.docs_resource.id
  description = "ID of /docs resource"
}

output "openapi_resource_id" {
  value       = aws_api_gateway_resource.openapi_resource.id
  description = "ID of /openapi.json resource"
}
