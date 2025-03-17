resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "${var.prefix}-codepipeline-artifacts-bucket"
  force_destroy = true
}

resource "aws_codepipeline" "api_codepipeline" {
  name = "${var.prefix}-api-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type = "S3"
    location = aws_s3_bucket.codepipeline_artifacts.bucket
  }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = var.api_repo_name
        BranchName = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = var.api_build_project_name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name = "Deploy"
      category = "Deploy"
      owner = "AWS"
      provider = "CodeDeploy"
      version = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ApplicationName = var.api_app_name
        DeploymentGroupName = var.api_deployment_group_name
      }
    }
  }
}

resource "aws_codepipeline" "merge_pipeline" {
  name = "${var.prefix}-merge-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type = "S3"
    location = aws_s3_bucket.codepipeline_artifacts.bucket
  }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = "1"
      output_artifacts = ["source_output"]
      configuration = {
        RepositoryName = var.api_repo_name
        BranchName = "release"
      }
    }
  }

  stage {
    name = "Merge"
    action {
      name            = "MergeBranches"
      category        = "Build"
      owner          = "AWS"
      provider      = "CodeBuild"
      input_artifacts = ["source_output"]
      version       = "1"
      configuration = {
        ProjectName = var.merge_builc_project_name
      }
    }
  }
}