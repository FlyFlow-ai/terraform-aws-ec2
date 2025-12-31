resource "aws_iam_role" "ecs_instance_role" {
  count = var.create_iam ? 1 : 0
  name  = "ecsInstanceRoleFinal"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  count = var.create_iam ? 1 : 0
  name  = "ecsInstanceProfile"
  role  = aws_iam_role.ecs_instance_role[0].name
}

resource "aws_iam_role_policy_attachment" "attachments" {
  for_each = var.create_iam ? toset(var.managed_policy_arns) : toset([])

  role       = aws_iam_role.ecs_instance_role[0].name
  policy_arn  = each.value
}

locals {
  instance_profile_name = var.create_iam
    ? aws_iam_instance_profile.ecs_instance_profile[0].name
    : var.iam_instance_profile_name
}
