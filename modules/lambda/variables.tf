variable "service_name" { type = string }
variable "environment" { type = string }
variable "lambda_role_arn" { type = string }
variable "source_dir" { type = string }

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "vpc_subnet_ids" {
  type    = list(string)
  default = []
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = []
}
