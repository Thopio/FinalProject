output "alb_name" {
  description = "ALB name for AWS CLI verification"
  value       = aws_lb.web.name
}

output "alb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = aws_lb.web.dns_name
}

output "target_group_arn" {
  description = "Target group ARN for AWS CLI health checks"
  value       = aws_lb_target_group.web.arn
}

output "instance_ids" {
  description = "Instance IDs keyed by logical server name"
  value       = { for name, instance in aws_instance.web : name => instance.id }
}

output "instance_public_ips" {
  description = "Public IPs keyed by logical server name"
  value       = { for name, instance in aws_instance.web : name => instance.public_ip }
}

output "selected_subnet_ids" {
  description = "Subnet IDs used by the ALB and EC2 instances"
  value       = local.selected_subnet_ids
}

output "selected_availability_zones" {
  description = "Availability Zones used by the selected subnets"
  value       = local.selected_azs
}
