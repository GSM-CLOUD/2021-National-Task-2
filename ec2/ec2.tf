resource "tls_private_key" "ec2-key" {
    algorithm = "RSA"
    rsa_bits = 2048

}

resource "aws_key_pair" "ec2-key-pair" {
  key_name = "${var.prefix}-key"
  public_key = tls_private_key.ec2-key.public_key_openssh
}

resource "local_file" "ec2_private_key" {
  content = tls_private_key.ec2-key.private_key_pem
  filename = "${path.module}/ec2_key.pem"
}

resource "aws_instance" "ec2_api_1" {
  ami = var.aws_ami
  instance_type = "t3.small"

  subnet_id = var.private_subnets[0]
  vpc_security_group_ids = [var.api_sg_id]
  key_name = aws_key_pair.ec2-key-pair.key_name
  iam_instance_profile = var.api_instance_profile_name
  associate_public_ip_address = false

  user_data = <<-EOF
#!/bin/bash
sudo su
set -e
set -x

sleep 120

echo "complete"
yum install -y docker
systemctl enable docker
systemctl restart docker

sudo yum install ruby -y
sudo yum install wget -y

wget https://aws-codedeploy-${var.region}.s3.${var.region}.amazonaws.com/latest/install
chmod +x ./install
./install auto

echo "complete"
aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com

echo "complete"
docker pull ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repo_name}:latest

echo "complete"
docker run -d -p 80:80 ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repo_name}:latest

systemctl start codedeploy-agent
systemctl enable codedeploy-agent
systemctl restart codedeploy-agent
EOF


  tags = {
    "Name" = "${var.prefix}-api-1"
    "wsi:deploy:group" = "dev-api"
  }
}

resource "aws_instance" "ec2_api_2" {
  ami = var.aws_ami
  instance_type = "t3.small"

  subnet_id = var.private_subnets[1]
  vpc_security_group_ids = [var.api_sg_id]
  key_name = aws_key_pair.ec2-key-pair.key_name
  iam_instance_profile = var.api_instance_profile_name
  associate_public_ip_address = false

  user_data = <<-EOF
#!/bin/bash
sudo su
set -e
set -x

echo "complete"
yum install -y docker
systemctl enable docker
systemctl restart docker

sudo yum install ruby -y
sudo yum install wget -y

wget https://aws-codedeploy-${var.region}.s3.${var.region}.amazonaws.com/latest/install
chmod +x ./install
./install auto

echo "complete"
aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com

echo "complete"
docker pull ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repo_name}:latest

echo "complete"
docker run -d -p 80:80 ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repo_name}:latest

systemctl start codedeploy-agent
systemctl enable codedeploy-agent
systemctl restart codedeploy-agent
EOF

  tags = {
    "Name" = "${var.prefix}-api-2"
    "wsi:deploy:group" = "dev-api"
  }

  depends_on = [ aws_instance.ec2_api_1 ]
}