variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "service_name" {
  description = "Used to prefix/tag all resources for this service"
  type        = string
  default     = "analytics-service"
}

# --- Database ---
# TODO: fill in once you have the RDS connection details.
variable "db_host" {
  description = "RDS MySQL endpoint hostname"
  type        = string
}

variable "db_port" {
  description = "RDS MySQL port"
  type        = number
  default     = 3306
}

variable "db_name" {
  description = "Database/schema name where user_behavior_events lives"
  type        = string
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN holding the scoped analytics DB user credentials"
  type        = string
}

# --- Networking (only needed if RDS is in a private VPC) ---
variable "vpc_subnet_ids" {
  description = "Private subnet IDs for Lambda VPC config, if RDS is private"
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "Security group IDs allowing Lambda to reach RDS on 3306"
  type        = list(string)
  default     = []
}

# --- CORS ---
variable "allowed_origin" {
  description = "Origin allowed to call this API (the frontend domain)"
  type        = string
  default     = "https://sapanafertilizer.com"
}
