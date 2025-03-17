output "api_app_name" {
  value = aws_codedeploy_app.api_app.name
}

output "api_deployment_group_name" {
  value = aws_codedeploy_deployment_group.api_app_dg.deployment_group_name
}