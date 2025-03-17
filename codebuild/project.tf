resource "aws_codebuild_project" "api_build" {
  name = "${var.prefix}-api-build"
  build_timeout = "5"

  service_role = aws_iam_role.api_build_role.arn

  source {
    type = "CODECOMMIT"
    location = "${var.api_repo_clone_url_http}"
    git_clone_depth = 1
  }

  source_version = "/refs/heads/main"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:6.0"
    type = "LINUX_CONTAINER"
    privileged_mode = true
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild_logs.name
      stream_name = "${var.prefix}-backend-log-stream"
    }
  }

  tags = {
    "Name" = "${var.prefix}-api-build"
  }
}

resource "aws_codebuild_project" "merge_build" {
  name = "${var.prefix}-merge-build"

  service_role = aws_iam_role.api_build_role.arn

  source {
    type = "CODECOMMIT"
    location = "${var.api_repo_clone_url_http}"
    git_clone_depth = 1
    buildspec = "buildspec-rel.yaml"
  }

  source_version = "/refs/heads/release"



  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }



  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild_logs.name
      stream_name = "${var.prefix}-merge-log-stream"
    }
  }

  tags = {
    "Name" = "${var.prefix}-merge-build"
  }
}