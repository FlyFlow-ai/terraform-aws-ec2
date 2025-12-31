# Terraform AWS ECS EC2 Cluster Module

This Terraform module provisions **EC2 instances** (configurable count) inside an existing **VPC/Subnets**, intended to be used as capacity for an **ECS cluster** (e.g., ECS-optimized AMI). It supports optional **user_data** for bootstrapping and optional **IAM creation** (or using an externally-managed instance profile).

## What this module does

- Launches `desired_count` EC2 instances across the provided `subnet_ids`
- Uses a provided AMI (default included)
- Allows configuring instance type and root volume settings
- Attaches **security groups** from `security_group_ids`
- Supports optional `user_data` for ECS cluster registration / bootstrapping
- Optionally creates an **IAM role + instance profile + policy attachments** for the instances
    - Or uses an externally-managed instance profile
- Tags instances with `Name = cluster_name`

> Note: This module assumes the VPC and subnets already exist.

---

## Requirements

- Terraform >= 1.3 (recommended)
- AWS provider installed

---

## Usage

### Basic example (module creates IAM by default)

```hcl
module "ecs_ec2" {
  source = "github.com/<ORG>/<REPO>//?ref=v1.0.0"

  vpc_id             = "vpc-xxxxxxxx"
  subnet_ids         = ["subnet-aaa", "subnet-bbb"]
  security_group_ids = ["sg-11111111111111111"]

  desired_count = 2
  cluster_name  = "flyflow-ecs-staging"

  # optional
  instance_type = "t3.micro"
  ami_id        = "ami-053e7be1410d7eb72"

  storage = {
    root_volume_size      = 30
    delete_on_termination = true
  }
}
```

### Example with `user_data`

```hcl
module "ecs_ec2" {
  source = "github.com/<ORG>/<REPO>//?ref=v1.0.0"

  vpc_id             = "vpc-xxxxxxxx"
  subnet_ids         = ["subnet-aaa", "subnet-bbb"]
  security_group_ids = ["sg-11111111111111111"]

  desired_count = 2
  cluster_name  = "flyflow-ecs-staging"

  user_data = <<-EOF
  #!/bin/bash
  set -e
  exec > >(tee -a /var/log/user-data.log) 2>&1

  echo "Bootstrapping ECS instance..."
  echo "ECS_CLUSTER=flyflow-ecs-staging" > /etc/ecs/ecs.config
  EOF
}
```

### Use IAM managed outside the module (recommended for flexibility)

Create IAM role/profile & attach policies in the root module, then pass the instance profile name:

```hcl
resource "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRoleFinal-staging"

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
  name = "ecsInstanceProfile-staging"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_ec2" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

module "ecs_ec2" {
  source = "github.com/<ORG>/<REPO>//?ref=v1.0.0"

  vpc_id             = "vpc-xxxxxxxx"
  subnet_ids         = ["subnet-aaa", "subnet-bbb"]
  security_group_ids = ["sg-11111111111111111"]

  desired_count = 2
  cluster_name  = "flyflow-ecs-staging"

  create_iam = false
  iam_instance_profile_name = aws_iam_instance_profile.ecs_instance_profile.name
}
```

---

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `vpc_id` | `string` | n/a | Default VPC ID for container |
| `subnet_ids` | `list(string)` | n/a | List of subnet IDs in the VPC |
| `instance_type` | `string` | `"t3.micro"` | EC2 instance type |
| `desired_count` | `number` | n/a | Desired count of instances |
| `cluster_name` | `string` | n/a | The cluster name used for ECS |
| `ami_id` | `string` | `"ami-053e7be1410d7eb72"` | AMI ID to use for instances |
| `storage` | `object({ root_volume_size = number, delete_on_termination = bool })` | `{ root_volume_size = 8, delete_on_termination = false }` | Root volume configuration |
| `user_data` | `string` | `null` | Raw user-data script |
| `security_group_ids` | `list(string)` | n/a | Security group IDs to attach |
| `create_iam` | `bool` | `true` | Whether the module creates IAM role/profile and attaches policies |
| `iam_instance_profile_name` | `string` | `null` | When `create_iam=false`, pass an existing instance profile name |
| `managed_policy_arns` | `list(string)` | `[AmazonEC2ContainerServiceforEC2Role]` | Managed policy ARNs to attach when `create_iam=true` |

---

## Outputs

| Name | Type | Description |
|------|------|-------------|
| `instance_ids` | `list(string)` | EC2 instance IDs |
| `public_ips` | `list(string)` | Public IPs (if public IP is associated) |
| `public_dns` | `list(string)` | Public DNS names |
| `private_ips` | `list(string)` | Private IPs |
| `private_dns` | `list(string)` | Private DNS names |
| `availability_zones` | `list(string)` | Availability Zones |
| `subnet_ids_used` | `list(string)` | Subnet IDs used by the instances |
| `instances` | `list(object)` | Structured instance details (id, ips, dns, az, subnet, type) |

### Example output usage

```hcl
output "ecs_instance_ids" {
  value = module.ecs_ec2.instance_ids
}

output "ecs_instances" {
  value = module.ecs_ec2.instances
}
```

---

## Notes / Assumptions

- Your subnets must allow the networking you need (public IP assignment, NAT, route tables, etc.).
- If you’re using ECS, ensure the AMI is ECS-optimized or your `user_data` installs/configures the ECS agent.
- Consider setting `storage.delete_on_termination = true` for ephemeral environments.
- For stable environments, prefer managing IAM outside the module (`create_iam=false`) to keep permissions explicit and environment-specific.

---

## License

MIT (or your preferred license)
