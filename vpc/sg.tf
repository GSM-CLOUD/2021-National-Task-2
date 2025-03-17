
/*
resource "aws_security_group" "service_sg" {
    name = "${var.prefix}-service-sg"
  vpc_id = module.vpc.vpc_id
  description = "${var.prefix}-service-sg"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-service-sg"
  }
}*/

