module "iam" {
  source         = "./modules/iam"
  project_prefix = var.project_prefix
}

module "networking" {
  source         = "./modules/networking"
  project_prefix = var.project_prefix
}