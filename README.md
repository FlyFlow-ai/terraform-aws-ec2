# Terraform AWS ECS EC2 Cluster Module

This Terraform module provisions **EC2 instances** (configurable count) inside an existing **VPC/Subnets**, intended to be used as capacity for an **ECS cluster** (e.g., ECS-optimized AMI). It also supports passing a custom **user_data** script to bootstrap instances.

## What this module does

- Launches `desired_count` EC2 instances across the provided `subnet_ids`
- Uses a provided AMI (default included)
- Allows configuring instance type and root volume settings
- Supports optional `user_data` for ECS cluster registration / bootstrapping
- Tags instances with `Name = cluster_name`

> Note: This module assumes the VPC and subnets already exist.

---

## Requirements

- Terraform >= 1.3 (recommended)
- AWS provider installed (module does not pin provider versions itself unless you choose to)

---

## Usage

### Basic example

```hcl
module "ecs_ec2" {
  source = "github.com/<ORG>/<REPO>//?ref=v1.0.0"

  vpc_id        = "vpc-xxxxxxxx"
  subnet_ids    = ["subnet-aaa", "subnet-bbb"]
  instance_type = "t3.micro"

  desired_count = 2
  cluster_name  = "flyflow-ecs-staging"

  # optional
  ami_id = "ami-053e7be1410d7eb72"

  storage = {
    root_volume_size      = 30
    delete_on_termination = true
  }
}
```

### Example with `user_data`

Pass a raw shell script string (heredoc). The module will attach it to the instance `user_data`.

```hcl
module "ecs_ec2" {
  source = "github.com/<ORG>/<REPO>//?ref=v1.0.0"

  vpc_id        = "vpc-xxxxxxxx"
  subnet_ids    = ["subnet-aaa", "subnet-bbb"]
  desired_count = 2
  cluster_name  = "flyflow-ecs-staging"

  user_data = <<-EOF
  #!/bin/bash
  set -e

  # Log user-data output
  exec > >(tee -a /var/log/user-data.log) 2>&1

  echo "Bootstrapping ECS instance..."
  echo "ECS_CLUSTER=flyflow-ecs-staging" > /etc/ecs/ecs.config
  EOF
}
```

> Tip: If you want `cluster_name` injected automatically into user_data, you can either:
> - build the string in the calling module using `templatefile()`, or
> - keep user_data simple and static.

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

---

## Outputs

This module currently does not define outputs. Common outputs you may want to add:
- `instance_ids`
- `private_ips`
- `public_ips`
- `security_group_id` (if created by the module)

---

## Notes / Assumptions

- Your subnets must allow the networking you need (public IP assignment, NAT, route tables, etc.).
- If you’re using ECS, ensure the AMI is ECS-optimized or your `user_data` installs/configures the ECS agent.
- Consider setting `delete_on_termination = true` in `storage` for ephemeral environments.

---


## License

MIT (or your preferred license)
