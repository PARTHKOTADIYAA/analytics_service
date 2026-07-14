variable "stage" { type = string }
variable "function_name" { type = string }
variable "lambda_iam_execution_role_arn" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "lambda_security_group_id" { type = string }
variable "central_api_gateway_execution_arn" { type = string }
variable "rds_endpoint" { type = string }
variable "db_user" { type = string }
variable "db_name" { type = string }
variable "region" {
  type    = string
  default = "ap-south-1"
}
