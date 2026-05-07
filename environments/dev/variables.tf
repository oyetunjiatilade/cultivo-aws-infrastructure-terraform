variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "owner" {
  description = "Owner team"
  type        = string
  default     = "platform-eng"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "isolated_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "cluster_version" {
  type    = string
  default = "1.27"
}

variable "cluster_endpoint_public_access" {
  type    = bool
  default = true
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "min_capacity" {
  type    = number
  default = 1
}

variable "max_capacity" {
  type    = number
  default = 3
}

variable "postgres_version" {
  type    = string
  default = "15.2"
}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.small"
}

variable "rds_allocated_storage" {
  type    = number
  default = 20
}

variable "database_name" {
  type    = string
  default = "devdb"
}

variable "master_username" {
  type    = string
  default = "postgres"
}

variable "master_password" {
  type      = string
  sensitive = true
}

variable "backup_retention_days" {
  type    = number
  default = 7
}
