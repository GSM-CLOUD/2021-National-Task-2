output "api_instance_profile_name" {
  value = aws_iam_instance_profile.api_instance_profile.name
}

output "api_sg_id" {
  value = aws_security_group.api-sg.id
}