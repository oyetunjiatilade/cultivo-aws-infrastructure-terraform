# This module is referenced by other modules for role creation
# The actual IAM roles are defined in their respective modules
# (EKS roles in eks/main.tf, RDS roles in rds/main.tf, etc.)

# External DNS IRSA Role
locals {
  common_tags = {
    Terraform = true
    ManagedBy = "terraform"
  }
}

output "roles_created" {
  value = "IAM roles managed in individual module files for better separation of concerns"
}
