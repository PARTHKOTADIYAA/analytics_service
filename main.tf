terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  # TODO: confirm these match the state-backend convention used by the
  # other service repos (e.g. homepage_service) before running apply.
  backend "s3" {
    bucket         = "REPLACE_ME_terraform_state_bucket"
    key            = "analytics_service/terraform.tfstate"
    region         = "REPLACE_ME_aws_region"
    dynamodb_table = "REPLACE_ME_terraform_lock_table"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "iam" {
  source       = "./modules/iam"
  service_name = var.service_name
  environment  = var.environment
}

module "lambda" {
  source          = "./modules/lambda"
  service_name    = var.service_name
  environment     = var.environment
  lambda_role_arn = module.iam.lambda_role_arn
  source_dir      = "${path.module}/src/app"

  # Only populated if RDS turns out to be in a private VPC
  vpc_subnet_ids         = var.vpc_subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids

  environment_variables = {
    DB_HOST       = var.db_host
    DB_PORT       = tostring(var.db_port)
    DB_NAME       = var.db_name
    DB_SECRET_ARN = var.db_secret_arn
  }
}

module "apigateway" {
  source               = "./modules/apigateway"
  service_name         = var.service_name
  environment          = var.environment
  lambda_invoke_arn    = module.lambda.invoke_arn
  lambda_function_name = module.lambda.function_name
}
