terraform {
  backend "s3" {
    bucket         = "juhi-tf-state-dev"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "juhi-terraform-lock-table-dev"
    encrypt        = true
  }
}
