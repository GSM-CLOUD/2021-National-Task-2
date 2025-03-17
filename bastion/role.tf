resource "aws_iam_role" "bastion_role" {
  name = "${var.prefix}-bastion-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "administrator_policy_attachment" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "${var.prefix}-bastion-instance-profile"
  role = aws_iam_role.bastion_role.name
}

resource "aws_iam_role" "api_role" {
  name = "${var.prefix}-api-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "api_instance_profile" {
  name = "${var.prefix}-api-instance-profile"
  role = aws_iam_role.api_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_policy_attachment" {
  role = aws_iam_role.api_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess"
}

resource "aws_iam_policy" "ecr_full_access" {
  name        = "ECRFullAccessPolicy"
  description = "Allows EC2 to access private ECR repositories"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:DescribeImages"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ecr_policy" {
  role       = aws_iam_role.api_role.name
  policy_arn = aws_iam_policy.ecr_full_access.arn
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role = aws_iam_role.api_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}