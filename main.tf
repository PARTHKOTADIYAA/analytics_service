terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region              = var.region
  allowed_account_ids = [var.account_id]
}

# Pull VPC, subnet, security group, and RDS info from customer_service
data "terraform_remote_state" "customer_service" {
  backend = "s3"
  config = {
    bucket = "terraform-state-git-${var.stage}"
    key    = "customer-service-${var.stage}-terraform/state.tfstate"
    region = "ap-south-1"
  }
}

# Pull central API Gateway info from auth_infra
data "terraform_remote_state" "auth_infra" {
  backend = "s3"
  config = {
    bucket = "terraform-state-git-${var.stage}"
    key    = "auth-infra-${var.stage}/terraform.tfstate"
    region = "ap-south-1"
  }
}

module "iam" {
  source = "./modules/iam"

  role_name       = "analytics-service-lambda-${var.stage}-iam-role"
  policy_name     = "analytics-service-lambda-${var.stage}-basic-execution"
  apigw_role_name = "analytics-api-gateway-cloudwatch-role-${var.stage}"
  stage           = var.stage
  region          = var.region
  account_id      = var.account_id

  rds_resource_id = data.terraform_remote_state.customer_service.outputs.rds_resource_id
  db_user         = var.db_username
}

module "lambda" {
  source = "./modules/lambda"

  stage         = var.stage
  function_name = "analytics-service"

  lambda_iam_execution_role_arn = module.iam.lambda_iam_execution_role_arn

  # Network — pulled from customer_service remote state
  private_subnet_ids       = [
    data.terraform_remote_state.customer_service.outputs.private_subnet_1_id,
    data.terraform_remote_state.customer_service.outputs.private_subnet_2_id,
  ]
  lambda_security_group_id = data.terraform_remote_state.customer_service.outputs.lambda_security_group_id

  # API Gateway permission
  central_api_gateway_execution_arn = data.terraform_remote_state.auth_infra.outputs.central_api_gateway_execution_arn

  # Database
  rds_endpoint = data.terraform_remote_state.customer_service.outputs.rds_endpoint
  db_user      = var.db_username
  db_name      = var.db_name
}

module "apigateway" {
  source = "./modules/apigateway"

  stage                      = var.stage
  apigateway_name            = "analytics-service-${var.stage}-api"
  lambda_function_name       = module.lambda.function_name
  lambda_function_invoke_arn = module.lambda.invoke_arn
  log_retention_days         = 14
}

module "cors" {
  source = "./modules/cors"

  rest_api_id     = module.apigateway.api_gateway_id
  resource_id     = module.apigateway.events_resource_id
  allowed_methods = ["POST", "OPTIONS"]
  allowed_origins = var.allowed_origins
}
