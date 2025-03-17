output "alb_tg_name" {
  value = aws_lb_target_group.api_tg.name
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "alb_tg_arn" {
  value = aws_lb_target_group.api_tg.arn
}