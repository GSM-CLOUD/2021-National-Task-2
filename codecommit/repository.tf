resource "aws_codecommit_repository" "api_repository" {
  repository_name = "${var.prefix}-api-repo"

  default_branch = "main"

  tags = {
    Name = "${var.prefix}-api-repo"
  }
}

/*
version: 0.2
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: arn:aws:ecs:${var.region}:${var.account_id}:task-definition/${var.task_definition_name}
        LoadBalancerInfo:
          ContainerName: ${var.container_name}
          ContainerPort: ${var.container_port}
        CapacityProviderStrategy:
        - Base: 2
          CapacityProvider: FARGATE_SPOT
          Weight: 1
        PlatformVersion: "LATEST"
        NetworkConfiguration:
          AwsvpcConfiguration:
            Subnets:
              - ${var.private_subnets[0]}
              - ${var.private_subnets[1]}
            SecurityGroups:
              - ${var.service_sg_id}
*/