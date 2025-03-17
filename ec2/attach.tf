resource "aws_lb_target_group_attachment" "alb_tg_api_1_attachment" {
  target_group_arn = var.alb_tg_arn
  target_id        =  aws_instance.ec2_api_1.id
  port            = 80
}

resource "aws_lb_target_group_attachment" "alb_tg_api_2_attachment" {
  target_group_arn = var.alb_tg_arn
  target_id        = aws_instance.ec2_api_2.id
  port            = 80
}