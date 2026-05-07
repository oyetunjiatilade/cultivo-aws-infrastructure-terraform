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
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "isolated_subnet_cidrs" {
  description = "Isolated subnet CIDRs"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.27"
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to EKS endpoint"
  type        = bool
  default     = false
}

variable "instance_types" {
  description = "EC2 instance types"
  type        = list(string)
  default     = ["t3.large"]
}

variable "desired_capacity" {
  description = "Desired capacity for spot nodes"
  type        = number
  default     = 3
}

variable "min_capacity" {
  description = "Min capacity for spot nodes"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Max capacity for spot nodes"
  type        = number
  default     = 10
}

variable "on_demand_desired_capacity" {
  description = "Desired capacity for on-demand nodes"
  type        = number
  default     = 2
}

variable "on_demand_min_capacity" {
  description = "Min capacity for on-demand nodes"
  type        = number
  default     = 2
}

variable "on_demand_max_capacity" {
  description = "Max capacity for on-demand nodes"
  type        = number
  default     = 5
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15.2"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.r5.xlarge"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 100
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "proddb"
}

variable "master_username" {
  description = "RDS master username"
  type        = string
  default     = "pgadmin"
}

variable "master_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "backup_retention_days" {
  description = "RDS backup retention days"
  type        = number
  default     = 35
}
