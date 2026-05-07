locals {
  common_tags = {
    Environment = var.environment
    Owner       = var.owner
    Terraform   = true
    ManagedBy   = "terraform"
    CreatedAt   = timestamp()
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-vpc"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-igw"
    }
  )
}

# Public Subnets (1 per AZ)
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name                              = "${var.environment}-public-${var.availability_zones[count.index]}"
      "kubernetes.io/role/elb"          = "1"
      "kubernetes.io/type/public-subnet" = "1"
    }
  )
}

# Private Subnets (1 per AZ)
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    local.common_tags,
    {
      Name                               = "${var.environment}-private-${var.availability_zones[count.index]}"
      "kubernetes.io/role/internal-elb"  = "1"
      "kubernetes.io/type/private-subnet" = "1"
    }
  )
}

# Isolated Subnets (1 per AZ)
resource "aws_subnet" "isolated" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.isolated_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-isolated-${var.availability_zones[count.index]}"
    }
  )
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = length(var.availability_zones)
  domain = "vpc"

  depends_on = [aws_internet_gateway.main]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-eip-nat-${var.availability_zones[count.index]}"
    }
  )
}

# NAT Gateways (1 per AZ in public subnet)
resource "aws_nat_gateway" "main" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-nat-${var.availability_zones[count.index]}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-public-rt"
    }
  )
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables (1 per AZ for NAT gateway locality)
resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-private-rt-${var.availability_zones[count.index]}"
    }
  )
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Isolated Route Table (no internet access)
resource "aws_route_table" "isolated" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-isolated-rt"
    }
  )
}

# Isolated Route Table Associations
resource "aws_route_table_association" "isolated" {
  count          = length(aws_subnet.isolated)
  subnet_id      = aws_subnet.isolated[count.index].id
  route_table_id = aws_route_table.isolated.id
}

# VPC Flow Logs S3 Bucket
resource "aws_s3_bucket" "flow_logs" {
  bucket = "${var.environment}-vpc-flow-logs-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-vpc-flow-logs"
    }
  )
}

resource "aws_s3_bucket_versioning" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# VPC Flow Logs IAM Role
resource "aws_iam_role" "vpc_flow_logs" {
  name = "${var.environment}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "${var.environment}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "s3:PutObject",
        "s3:GetObject"
      ]
      Effect   = "Allow"
      Resource = "${aws_s3_bucket.flow_logs.arn}/*"
    }]
  })
}

# VPC Flow Logs
resource "aws_flow_log" "main" {
  iam_role_arn            = aws_iam_role.vpc_flow_logs.arn
  log_destination         = "${aws_s3_bucket.flow_logs.arn}/"
  traffic_type            = "ALL"
  vpc_id                  = aws_vpc.main.id
  log_destination_type    = "s3"
  log_format              = "${aws_vpc.main.id} $${version} $${account_id} $${interface_id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${windowstart} $${windowend} $${action} $${tcpflags} $${type} $${pkt_srcaddr} $${pkt_dstaddr}"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-vpc-flow-logs"
    }
  )
}

# DHCP Options Set
resource "aws_vpc_dhcp_options" "main" {
  domain_name          = "ec2.internal"
  domain_name_servers  = ["AmazonProvidedDNS"]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-dhcp-options"
    }
  )
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id             = aws_vpc.main.id
  dhcp_options_id    = aws_vpc_dhcp_options.main.id
}

# Data source for account ID
data "aws_caller_identity" "current" {}
