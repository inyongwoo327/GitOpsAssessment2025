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

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.sample.id
}