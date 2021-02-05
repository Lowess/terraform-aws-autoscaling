variable "aws_region" {}

variable "aws_profile" {}

variable "vpc_name" {
  type        = string
  description = "VPC Name"
}

variable "app_name" {
  type        = string
  description = "Name of the application"
}

variable "app_port" {
  type        = number
  default     = 8080
  description = "The port the application is listening on"
}
variable "app_ami_owner" {
  type        = string
  description = "Account Id owner of the AMI"
}

variable "app_ami_name" {
  type        = string
  description = "AMI Name of the application"
}

variable "app_tags" {
  default     = {}
  description = "Set of tags to apply to the application"
}

variable "app_desired_size" {
  default     = 0
  description = "Desired number of application instances in the ASG"
}

variable "app_min_size" {
  default     = 0
  description = "Minimum number of application instances in the ASG"
}

variable "app_max_size" {
  default     = 3
  description = "Maximum number of application instances in the ASG"
}

variable "app_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Type of instance to use for the application"
}

variable "app_key_name" {
  type        = string
  description = "Name of the keypair to use for the application"
}

variable "app_root_block_device" {
  default = {
    volume_type = "gp2"
    volume_size = 20
  }

  description = "An EBS block device block definition to use by the application"
}
