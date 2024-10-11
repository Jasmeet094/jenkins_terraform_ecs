locals {
  default_tags = {
    Environment = terraform.workspace
  }
  tags = merge(local.default_tags, var.tags)
}

# Create the IAM role for ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.identifier}-${terraform.workspace}-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "${var.aws_service_principal}"
        }
      }
    ]
  })
  tags = var.tags

}

# IAM Policy attachment for ecs task execution role 
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create the IAM role for ECS auto-scaling
resource "aws_iam_role" "ecs_auto_scale_role" {
  name = "${var.identifier}-${terraform.workspace}-auto_scale-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "application-autoscaling.amazonaws.com"
        }
      }
    ]
  })
  tags = var.tags
}

# If need more policies then add policies in tfvar file in service variable)
resource "aws_iam_role_policy_attachment" "attach" {
  count = length(var.iam_policies_to_attach)

  policy_arn = element(var.iam_policies_to_attach, count.index)
  role       = aws_iam_role.ecs_task_execution_role.name
}

# Create the IAM role for ECS tasks
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.identifier}-${terraform.workspace}-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "${var.aws_service_principal}"
        }
      }
    ]
  })
  tags = var.tags
}

# Create the IAM policy for ECS tasks
data "aws_iam_policy_document" "jenkins_controller_task_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:ListContainerInstances",
      "ecs:DescribeClusters",
      "ecs:StopTask"
    ]
    resources = [
      for arn in var.ecs_cluster_arns : arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:RunTask"
    ]
    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values = [
        for arn in var.ecs_cluster_arns : arn
      ]
    }
    resources = ["arn:aws:ecs:${var.region}:${var.aws_account_id}:task-definition/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:StopTask",
      "ecs:DescribeTasks"
    ]
    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values = [
        for arn in var.ecs_cluster_arns : arn
      ]
    }
    resources = ["arn:aws:ecs:${var.region}:${var.aws_account_id}:task/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["arn:aws:iam::${var.aws_account_id}:role/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:RunTask"
    ]
    resources = ["arn:aws:ecs:${var.region}:${var.aws_account_id}:task-definition/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken",
      "ecs:RegisterTaskDefinition",
      "ecs:ListClusters",
      "ecs:DescribeContainerInstances",
      "ecs:ListTagsForResource",
      "ecs:ListTaskDefinitions",
      "ecs:DescribeTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecrets",
      "ecs:TagResource"

    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems"
    ]
    resources = [var.efs_arn]
  }
}

resource "aws_iam_policy" "ecs_task_policy" {
  name        = "${var.identifier}-${terraform.workspace}-task-policy"
  description = "Policy for ECS tasks"
  policy      = data.aws_iam_policy_document.jenkins_controller_task_policy.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}