resource "aws_instance" "ecs_instance" {
  count          = var.desired_count
  ami            = var.ami_id # ecs-flyflow AMI image
  instance_type  = var.instance_type
  subnet_id      = element(var.subnet_ids, count.index % length(var.subnet_ids))
  security_groups = var.security_group_ids

  associate_public_ip_address = true
  iam_instance_profile = local.instance_profile_name

  root_block_device {
    volume_size = var.storage.root_volume_size # Set the desired storage size in GB (e.g., 50 GB)
    volume_type = "gp3"     # General-purpose SSD (gp3) for better performance
    delete_on_termination = var.storage.delete_on_termination  # Ensures the volume is deleted when the instance is terminated
  }


  user_data = var.user_data

  tags = {
    Name = var.cluster_name
  }
}