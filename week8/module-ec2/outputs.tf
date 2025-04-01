output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.security_group_ec2.id
}

output "autoscaling_group_name" {
  description = "Name of the autoscaling group"
  value       = aws_autoscaling_group.autoscale.name
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.sample_launch_template.id
}

output "vpc_id" {
  description = "ID of the VPC created by this module"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
}