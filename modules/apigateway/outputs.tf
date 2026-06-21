output "rest_api_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "events_resource_id" {
  value = aws_api_gateway_resource.events.id
}

output "api_endpoint" {
  value = aws_api_gateway_stage.this.invoke_url
}
