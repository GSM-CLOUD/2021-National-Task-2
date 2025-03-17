resource "aws_security_group" "bastion-sg" {
  vpc_id = var.vpc_id
  description = "bastion-sg"
  ingress = [{
    description = "bastion-sg"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }]

  egress = [{
    description = "bastion-sg"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }]


  tags = {
    "Name" = "${var.prefix}-bastion-sg"
  }
}

resource "aws_security_group" "api-sg" {
  vpc_id = var.vpc_id
  description = "api-sg"
  ingress = [{
    description = "api-sg"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  },
  {
    description = "api-sg"
    cidr_blocks = []
    from_port = 80
    to_port = 80
    protocol = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = [var.alb_sg_id]
    self = false
  }
  ]

  egress = [{
    description = "api-sg"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }]


  tags = {
    "Name" = "${var.prefix}-api-sg"
  }
}