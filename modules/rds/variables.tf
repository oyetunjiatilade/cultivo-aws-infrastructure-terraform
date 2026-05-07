variable "environment" {
  description = "Environment name"
  type        = string
}

variable "owner" {
  description = "Owner team name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "isolated_subnet_ids" {
  description = "Isolated subnet IDs for RDS"
  type        = list(string)
}

variable "eks_node_security_group_id" {
  description = "EKS node security group ID"
  type        = string
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15.2"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Max allocated storage for autoscaling"
  type        = number
  default     = 100
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "master_username" {
  description = "Master username"
  type        = string
  default     = "postgres"
}

variable "master_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "backup_retention_days" {
  description = "Backup retention in days"
  type        = number
  default     = 35
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot"
  type        = bool
  default     = false
}
