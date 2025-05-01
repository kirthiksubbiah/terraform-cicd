output "internal_app_lb_dns" {
  description = "DNS of internal loadbalancer"
  value       = aws_lb.internal_app_lb.dns_name
}

output "external_app_lb_dns" {
  description = "DNS of external loadbalancer"
  value       = aws_lb.external_web_lb.dns_name
}

output "external_web_lb_arn" {
  description = "arn of external loadbalancer"
  value       = aws_lb.external_web_lb.arn
}