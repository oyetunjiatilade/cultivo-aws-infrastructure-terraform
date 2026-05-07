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

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.27"
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to cluster endpoint"
  type        = bool
  default     = true
}

variable "instance_types" {
  description = "EC2 instance types for node groups"
  type        = list(string)
  default     = ["t3.medium", "t3.large"]
}

variable "desired_capacity" {
  description = "Desired capacity for spot node group"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum capacity for spot node group"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum capacity for spot node group"
  type        = number
  default     = 6
}

variable "on_demand_desired_capacity" {
  description = "Desired capacity for on-demand node group"
  type        = number
  default     = 1
}

variable "on_demand_min_capacity" {
  description = "Minimum capacity for on-demand node group"
  type        = number
  default     = 1
}

variable "on_demand_max_capacity" {
  description = "Maximum capacity for on-demand node group"
  type        = number
  default     = 3
}
