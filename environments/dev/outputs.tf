output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "cluster_autoscaler_role_arn" {
  value = module.eks.cluster_autoscaler_role_arn
}
