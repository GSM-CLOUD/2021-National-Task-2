output "api_repo_clone_url_http" {
  value = aws_codecommit_repository.api_repository.clone_url_http
}

output "api_repo_name" {
  value = aws_codecommit_repository.api_repository.repository_name
}