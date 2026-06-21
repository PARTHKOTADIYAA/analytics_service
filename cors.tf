# Split into its own file to match the convention seen in homepage_service,
# where CORS is configured separately from the main API Gateway resources.
module "cors" {
  source         = "./modules/cors"
  rest_api_id    = module.apigateway.rest_api_id
  resource_id    = module.apigateway.events_resource_id
  allowed_origin = var.allowed_origin
}
