variable "project_prefix" {
  description = "Project prefix to be used in naming the bucket"
  type        = string
}
variable "external_web_lb_arn" {
  description = "arn of external loadbalancer"
  type        = string
}