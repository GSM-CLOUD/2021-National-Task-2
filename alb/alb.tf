resource "aws_lb" "alb" {
  name = "${var.prefix}-api-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = ["${var.public_subnets[0]}", "${var.public_subnets[1]}"]
  enable_deletion_protection = false
}