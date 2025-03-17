resource "aws_ecr_repository" "api_ecr" {
    name = "${var.prefix}-api-ecr"
    image_tag_mutability = "MUTABLE"
    force_delete = true
    image_scanning_configuration {
      scan_on_push = true
    }

    tags = {
      "Name" = "${var.prefix}-api-ecr"
    }
}