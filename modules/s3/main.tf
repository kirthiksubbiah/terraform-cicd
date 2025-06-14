terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Generate a random suffix to avoid bucket name collisions
resource "random_id" "suffix" {
  byte_length = 4
}

# Define the bucket name using a local variable
locals {
  bucket_name = "${var.project_prefix}-code-bucket-${random_id.suffix.hex}"
}

# Create the S3 bucket
resource "aws_s3_bucket" "terraform_bucket_juhi" {
  bucket        = local.bucket_name
  force_destroy = true
}

# Disable all public access blocks (required for public policy to work)
resource "aws_s3_bucket_public_access_block" "allow_public" {
  bucket = aws_s3_bucket.terraform_bucket_juhi.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Attach a public-read policy to allow GetObject for everyone
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.terraform_bucket_juhi.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.terraform_bucket_juhi.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.allow_public]
}

# Outputs for reference
# output "bucket_name" {
#   description = "Name of the public S3 bucket"
#   value       = local.bucket_name
# }

# output "bucket_arn" {
#   description = "ARN of the public S3 bucket"
#   value       = aws_s3_bucket.terraform_bucket_juhi.arn
# }

# output "bucket_url" {
#   description = "Public URL of the S3 bucket"
#   value       = "https://${local.bucket_name}.s3.amazonaws.com"
# }
