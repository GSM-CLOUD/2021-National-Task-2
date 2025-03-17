module "vpc" {
  source = "./vpc"
  prefix = var.prefix
  region = var.region
}

module "codecommit" {
  source = "./codecommit"
  prefix = var.prefix

  depends_on = [ module.vpc ]
}

module "ecr" {
  source = "./ecr"
  prefix = var.prefix
  
  depends_on = [ module.codecommit ]
}

module "s3" {
  source = "./s3"
  prefix = var.prefix

  depends_on = [ module.ecr ]
}


module "alb" {
  source = "./alb"
  prefix = var.prefix
  vpc_id = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets

  depends_on = [ module.s3 ]
}

module "bastion" {
  source = "./bastion"
  prefix = var.prefix
  public_subnets = module.vpc.public_subnets
  aws_ami = data.aws_ami.al2023_ami_amd.id
  vpc_id = module.vpc.vpc_id
  account_id = data.aws_caller_identity.current.account_id
  region = var.region
  ecr_repo_name = module.ecr.ecr_repo_name
  api_repo_name = module.codecommit.api_repo_name
  bucket_file_name = module.s3.bucket_file_name
  default_branch = var.default_branch
  instance_type = var.instance_type
  private_subnets = module.vpc.private_subnets
  alb_sg_id = module.alb.alb_sg_id
  alb_tg_arn = module.alb.alb_tg_arn

  depends_on = [ module.alb ]
}

module "ec2" {
  source = "./ec2"
  prefix = var.prefix
  private_subnets = module.vpc.private_subnets
  aws_ami = data.aws_ami.al2023_ami_amd.id
  vpc_id = module.vpc.vpc_id
  api_sg_id = module.bastion.api_sg_id
  api_instance_profile_name = module.bastion.api_instance_profile_name
  alb_tg_arn = module.alb.alb_tg_arn
  region = var.region
  account_id = data.aws_caller_identity.current.account_id
  ecr_repo_name = module.ecr.ecr_repo_name

  depends_on = [ module.bastion ]
}

module "codebuild" {
  source = "./codebuild"
  prefix = var.prefix
  api_repo_clone_url_http = module.codecommit.api_repo_clone_url_http

  depends_on = [ module.ec2 ]  
}


module "codedeploy" {
  source = "./codedeploy"
  alb_tg_name = module.alb.alb_tg_name
  prefix = var.prefix

  depends_on = [ module.codebuild ]
}

module "codepipeline" {
  source = "./codepipline"
  prefix = var.prefix
  api_repo_name = module.codecommit.api_repo_name
  api_build_project_name = module.codebuild.api_build_project_name
  api_app_name = module.codedeploy.api_app_name
  api_deployment_group_name = module.codedeploy.api_deployment_group_name
  account_id = data.aws_caller_identity.current.account_id
  region = var.region
  merge_builc_project_name = module.codebuild.merge_builc_project_name

  depends_on = [ module.codedeploy ]
}