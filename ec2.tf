resource "aws_instance" "ecs_instance" {
  count          = var.desired_count
  ami            = var.ami_id # ecs-flyflow AMI image
  instance_type  = var.instance_type
  subnet_id      = element(var.subnet_ids, count.index % length(var.subnet_ids))
  security_groups = [aws_security_group.ecs_sg.id]

  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name

  root_block_device {
    volume_size = var.storage.root_volume_size # Set the desired storage size in GB (e.g., 50 GB)
    volume_type = "gp3"     # General-purpose SSD (gp3) for better performance
    delete_on_termination = var.storage.delete_on_termination  # Ensures the volume is deleted when the instance is terminated
  }


  user_data = <<-EOF
#!/bin/bash
# Redirect all output to a custom log file for debugging.
exec > >(tee -a /var/log/user-data-custom.log) 2>&1

echo "User data script started at $(date)"

echo "Step 1: Updating system packages"
yum update -y


echo "Step 5: Setting ECS_CLUSTER environment variable"
echo "ECS_CLUSTER=${var.cluster_name}" > /etc/ecs/ecs.config
echo "ECS_CLUSTER configuration applied"



echo "User data script finished at $(date)"

EOF

  tags = {
    Name = var.cluster_name
  }
}