terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "dev"
      ManagedBy   = "terraform"
      Terraform   = true
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  environment         = "dev"
  owner               = var.owner
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  isolated_subnet_cidrs = var.isolated_subnet_cidrs
}

module "eks" {
  source = "../../modules/eks"

  environment              = "dev"
  owner                    = var.owner
  vpc_id                   = module.vpc.vpc_id
  vpc_cidr                 = module.vpc.vpc_cidr
  private_subnet_ids       = module.vpc.private_subnet_ids
  cluster_version          = var.cluster_version
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  instance_types           = var.instance_types
  desired_capacity         = var.desired_capacity
  min_capacity             = var.min_capacity
  max_capacity             = var.max_capacity
}

module "rds" {
  source = "../../modules/rds"

  environment                = "dev"
  owner                      = var.owner
  vpc_id                     = module.vpc.vpc_id
  isolated_subnet_ids        = module.vpc.isolated_subnet_ids
  eks_node_security_group_id = module.eks.node_security_group_id
  postgres_version           = var.postgres_version
  instance_class             = var.rds_instance_class
  allocated_storage          = var.rds_allocated_storage
  database_name              = var.database_name
  master_username            = var.master_username
  master_password            = var.master_password
  backup_retention_days      = var.backup_retention_days
  skip_final_snapshot        = true
}
