data "aws_ami" "al2023_ami_amd" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*kernel-6.1*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_caller_identity" "current" {}

/*
data "aws_prefix_list" "cloudfront" {
  prefix_list_id = "pl-22a6434b"
}

output "cloudfront_prefix_list_id" {
  value = data.aws_prefix_list.cloudfront.prefix_list_id
}*/
