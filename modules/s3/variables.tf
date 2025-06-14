variable "project_prefix" {
  description = "Prefix for bucket name"
  type        = string
  default     = "bootcamp1"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}
