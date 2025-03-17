resource "aws_codedeploy_deployment_group" "api_app_dg" {
  app_name = aws_codedeploy_app.api_app.name
  deployment_group_name = "dev-api"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn = aws_iam_role.codedeploy_role.arn

  auto_rollback_configuration {
    enabled = true
    events = ["DEPLOYMENT_FAILURE"]
  }

  ec2_tag_set {
    ec2_tag_filter {
      key = "${var.prefix}:deploy:group"
      type = "KEY_AND_VALUE"
      value = "dev-api"
    }
  }

  load_balancer_info {
    target_group_info {
      name = var.alb_tg_name
    }
  }
}