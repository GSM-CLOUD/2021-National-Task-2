resource "aws_codedeploy_app" "api_app" {
  name             = "${var.prefix}-api"
  compute_platform = "Server"
}