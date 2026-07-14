variable "rest_api_id" {
  type = string
}

variable "resource_id" {
  type = string
}

variable "allowed_methods" {
  type    = list(string)
  default = ["POST", "OPTIONS"]
}

variable "allowed_origins" {
  type    = string
  default = "*"
}
