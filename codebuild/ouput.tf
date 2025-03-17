output "api_build_project_name" {
  value = aws_codebuild_project.api_build.name
}

output "merge_builc_project_name" {
  value = aws_codebuild_project.merge_build.name
}