terraform {
  backend "s3" {
    bucket         = "kirthik-tf-state-dev-pipeline"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "kirthik-terraform-lock-table-dev"
    encrypt        = true
  }
}
