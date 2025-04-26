output "aurora_writer" {
  description = "RDS writer endpoint"
  value       = aws_rds_cluster_instance.aurora_writer.endpoint
}