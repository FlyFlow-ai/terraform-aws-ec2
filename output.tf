output "instance_ids" {
  description = "EC2 instance IDs"
  value       = aws_instance.ecs_instance[*].id
}

output "public_ips" {
  description = "Public IPs (if associate_public_ip_address=true)"
  value       = aws_instance.ecs_instance[*].public_ip
}

output "public_dns" {
  description = "Public DNS names"
  value       = aws_instance.ecs_instance[*].public_dns
}

output "private_ips" {
  description = "Private IPs"
  value       = aws_instance.ecs_instance[*].private_ip
}

output "private_dns" {
  description = "Private DNS names"
  value       = aws_instance.ecs_instance[*].private_dns
}

output "availability_zones" {
  description = "Availability Zones"
  value       = aws_instance.ecs_instance[*].availability_zone
}

output "subnet_ids" {
  description = "Subnet IDs used"
  value       = aws_instance.ecs_instance[*].subnet_id
}
