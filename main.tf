module "s3" {
  source         = "./modules/s3"
  project_prefix = var.project_prefix
}

module "iam" {
  source         = "./modules/iam"
  project_prefix = var.project_prefix
}

module "networking" {
  source         = "./modules/networking"
  project_prefix = var.project_prefix
}

module "rds" {
  source               = "./modules/rds"
  project_prefix       = var.project_prefix
  db_subnet_group_name = module.networking.db_subnet_group_name
  aws_security_group   = module.networking.aws_security_group
}