locals {
  common_tags = {
    Environment = var.environment
    Owner       = var.owner
    Terraform   = true
    ManagedBy   = "terraform"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = var.isolated_subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-rds-subnet-group"
    }
  )
}

resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-rds-sg"
    }
  )
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.environment}-postgres-params"
  family = "postgres15"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  parameter {
    name  = "max_connections"
    value = "100"
  }

  tags = merge(local.common_tags, {Name = "${var.environment}-postgres-params"})
}

resource "aws_db_option_group" "main" {
  name                     = "${var.environment}-postgres-options"
  option_group_description = "Option group for PostgreSQL"
  engine_name              = "postgres"
  major_engine_version     = "15"

  tags = merge(local.common_tags, {Name = "${var.environment}-postgres-options"})
}

resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(local.common_tags, {Name = "${var.environment}-rds-key"})
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.environment}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

resource "aws_db_instance" "main" {
  identifier            = "${var.environment}-postgres"
  engine                = "postgres"
  engine_version        = var.postgres_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.rds.arn

  db_name  = var.database_name
  username = var.master_username
  password = var.master_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.main.name
  option_group_name      = aws_db_option_group.main.name

  multi_az = true

  backup_retention_period = var.backup_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"
  copy_tags_to_snapshot   = true

  enabled_cloudwatch_logs_exports = ["postgresql"]

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${var.environment}-postgres-final"

  enable_iam_database_authentication = true
  deletion_protection               = var.environment == "prod" ? true : false

  performance_insights_enabled = true
  performance_insights_kms_key_id = aws_kms_key.rds.arn

  tags = merge(local.common_tags, {Name = "${var.environment}-postgres"})

  lifecycle {
    ignore_changes = [password]
  }
}

resource "aws_iam_role" "rds_monitoring" {
  name = "${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.rds_monitoring.name
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.environment}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when RDS CPU exceeds 80%"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = local.common_tags
}
