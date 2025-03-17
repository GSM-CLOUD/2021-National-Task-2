resource "aws_lb_target_group" "api_tg" {
    name = "${var.prefix}-api-tg"
    port = 80
    protocol = "HTTP"
    target_type = "instance"
    vpc_id = var.vpc_id

    health_check {
      path = "/health"
      interval = 30
      timeout = 5
      healthy_threshold = 3
      unhealthy_threshold = 3 
    }

    tags = {
      Name = "${var.prefix}-api-tg"
    }
} 