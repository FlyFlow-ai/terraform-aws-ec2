variable "vpc_id" {
  type        = string
  description = "Default VPC ID for container"
}
variable "subnet_ids" {
  description = "List of subnet IDs in the VPC"
  type        = list(string)
}
variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Default Subnet ID for container"
}
variable "desired_count" {
  type        = number
  description = "Desired count of instances"
}
variable "cluster_name" {
  type        = string
  description = "The cluster name used for ECS "
}

variable "ami_id" {
  type        = string
  default     = "ami-053e7be1410d7eb72"
}
variable "storage" {
  type        = object({
    root_volume_size      = number
    delete_on_termination     = bool

  })
  default = {
    root_volume_size = 8
    delete_on_termination = false
  }
}

variable "user_data" {
  description = "Raw user-data script"
  type        = string
  default     = null
}