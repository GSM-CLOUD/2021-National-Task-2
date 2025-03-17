resource "tls_private_key" "bastin-key" {
    algorithm = "RSA"
    rsa_bits = 2048

}

resource "aws_key_pair" "bastion-key-pair" {
  key_name = "${var.prefix}-bastion-key"
  public_key = tls_private_key.bastin-key.public_key_openssh
}

resource "local_file" "bastion_private_key" {
  content = tls_private_key.bastin-key.private_key_pem
  filename = "${path.module}/bastion_key.pem"
}

resource "aws_instance" "bastion" {
  ami = var.aws_ami
  instance_type = "t3a.small"

  subnet_id = var.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  key_name = aws_key_pair.bastion-key-pair.key_name
  iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name

    user_data = <<-EOF
#!/bin/bash
sudo su
set -e
set -x

echo "complete"
yum install -y docker
systemctl enable docker
systemctl restart docker

echo "complete"
cat <<EOT > buildspec-rel.yaml
version: 0.2

phases:
  build:
    commands:
      - echo "Clone repository"
      - git config --global user.email "codebuild@yourdomain.com"
      - git config --global user.name "AWS CodeBuild"
      - git config --global credential.helper '!aws codecommit credential-helper $@'
      - git config --global credential.UseHttpPath true
      - git clone -b release https://git-codecommit.${var.region}.amazonaws.com/v1/repos/${var.api_repo_name}
      - cd ${var.api_repo_name}
      - git init
      - git checkout -b main
      - git push origin main
EOT

echo "complete"
cat <<EOT > buildspec.yaml
version: 0.2

env:
  shell: bash
  variables:
    ACCOUNT_ID: ${var.account_id}
    AWS_REGION: ${var.region}
    REPO_NAME: ${var.ecr_repo_name}
phases:
  pre_build:
    commands:
      - echo "Logging in to Amazon ECR..."
      - aws ecr get-login-password --region \$AWS_REGION | docker login --username AWS --password-stdin \$ACCOUNT_ID.dkr.ecr.\$AWS_REGION.amazonaws.com
      - IMAGE_TAG=$(date '+%Y%m%d%H%M%S')
      - echo \$IMAGE_TAG
  build:
    commands:
      - echo "Building Docker image"
      - docker build -t \$REPO_NAME:\$IMAGE_TAG .
      - docker tag \$REPO_NAME:\$IMAGE_TAG \$ACCOUNT_ID.dkr.ecr.\$AWS_REGION.amazonaws.com/\$REPO_NAME:\$IMAGE_TAG
  post_build:
    commands:
      - echo "Pushing Docker image to ECR"
      - docker push \$ACCOUNT_ID.dkr.ecr.\$AWS_REGION.amazonaws.com/\$REPO_NAME:\$IMAGE_TAG
      - printf '[{"name":"wsi-api-container","imageUri":"%s"}]' "\$ACCOUNT_ID.dkr.ecr.\$AWS_REGION.amazonaws.com/\$REPO_NAME:\$IMAGE_TAG" > imagedefinitions.json
artifacts:
  files:
    - imagedefinitions.json
    - appspec.yml
    - start_container.sh
    - stop_container.sh
EOT

cat <<EOT > /opt/ec2_launch.sh
#!/bin/bash

EC2_NAME=\$1
AWS_REGION=${var.region}
AMI_ID=${var.aws_ami}
INSTANCE_TYPE=${var.instance_type}
SUBNET_ID=${var.private_subnets[0]}
SECURITY_GROUP_ID=${aws_security_group.api-sg.id}
IAM_ROLE=${aws_iam_instance_profile.api_instance_profile.name}
TARGET_GROUP_ARN=${var.alb_tg_arn}

echo "complete1"
yum install -y aws-cli

echo "complete2"
EXISTING_INSTANCE_ID=\$(aws ec2 describe-instances --filters "Name=tag:Name,Values=\$EC2_NAME" "Name=instance-state-name,Values=pending,running" --query "Reservations[*].Instances[*].InstanceId" --output text)

echo "complete userdata"
USER_DATA=\$(cat <<END
#!/bin/bash
sudo su
yum install docker -y
systemctl enable docker
systemctl restart docker

sudo yum install ruby -y
sudo yum install wget -y

wget https://aws-codedeploy-${var.region}.s3.${var.region}.amazonaws.com/latest/install
chmod +x ./install
./install auto

systemctl start codedeploy-agent
systemctl enable codedeploy-agent
systemctl restart codedeploy-agent
END
)

echo "complete3"
INSTANCE_ID=\$(aws ec2 run-instances \
    --image-id \$AMI_ID \
    --instance-type \$INSTANCE_TYPE \
    --subnet-id \$SUBNET_ID \
    --security-group-ids \$SECURITY_GROUP_ID \
    --iam-instance-profile Name=\$IAM_ROLE \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=\$EC2_NAME},{Key=wsi:deploy:group,Value=dev-api}]" \
    --user-data "\$USER_DATA" \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "complete4"
aws ec2 wait instance-running --instance-ids \$INSTANCE_ID

echo "complete5"
aws elbv2 register-targets --target-group-arn \$TARGET_GROUP_ARN --targets Id=\$INSTANCE_ID
EOT

echo "complete"
yum install git -y

export HOME=/root
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

git clone https://git-codecommit.${var.region}.amazonaws.com/v1/repos/${var.api_repo_name}

echo "complete"
aws s3 cp s3://${var.bucket_file_name}/backend/ ./${var.api_repo_name} --recursive

mv ./buildspec.yaml ./${var.api_repo_name}/
mv ./buildspec-rel.yaml ./${var.api_repo_name}/

cd ${var.api_repo_name}


echo "complete"
aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com
docker build -t ${var.ecr_repo_name} .
docker tag ${var.ecr_repo_name}:latest ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repo_name}:latest
docker push ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repo_name}:latest

echo "complete"
git init
git add .
git commit -m "Initial commit"
git checkout -b ${var.default_branch}
git push origin ${var.default_branch}

git checkout -b release
git push origin release
EOF

  tags = {
    "Name" = "${var.prefix}-bastion-ec2"
  }
}

resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
  
  tags = {
    Name = "${var.prefix}-bastion-eip"
  }
}