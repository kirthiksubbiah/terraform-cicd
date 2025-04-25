module "iam" {
  source         = "./modules/iam"
  project_prefix = var.project_prefix
}
