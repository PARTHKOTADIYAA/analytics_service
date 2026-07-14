variable "region" {
  type        = string
  description = "AWS region"
  default     = "ap-south-1"
}

variable "account_id" {
  type        = string
  description = "AWS account ID"
}

variable "stage" {
  type        = string
  description = "Deployment stage (dev/prod)"
}

variable "db_username" {
  type        = string
  description = "IAM DB username for the analytics Lambda"
}

variable "db_name" {
  type        = string
  description = "Database/schema name for analytics table"
}

variable "allowed_origins" {
  type        = string
  description = "CORS allowed origin"
  default     = "https://sapanafertilizer.com"
}
