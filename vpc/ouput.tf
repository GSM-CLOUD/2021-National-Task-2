output "public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

/*
output "service_sg_id" {
  value = aws_security_group.service_sg.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}*/