output "s3_bucket_name" {
  description = "S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  description = "DynamoDB table for Terraform locking"
  value       = aws_dynamodb_table.terraform_lock.id
}

output "terraform_ci_role_arn" {
  description = "IAM role ARN for Terraform CI/CD"
  value       = aws_iam_role.terraform_ci_role.arn
}

output "state_backend_config" {
  description = "Backend config for terraform init"
  value = {
    bucket         = aws_s3_bucket.terraform_state.id
    dynamodb_table = aws_dynamodb_table.terraform_lock.id
    region         = var.aws_region
  }
}
