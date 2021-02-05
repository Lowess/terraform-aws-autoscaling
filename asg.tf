######################################################################
## Security groups
######################################################################

resource "aws_security_group" "asg" {
  vpc_id      = module.discovery.vpc_id
  name        = var.app_name
  description = "${var.app_name} - Security group"
  tags        = merge(var.app_tags, map("Name", format("%s", var.app_name)))

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Configuration of the firewall - Instances <-> ALB
resource "aws_security_group_rule" "asg_tcp_alb" {
  type                     = "ingress"
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.asg.id
}

# Configuration of the firewall - Instances <-> MyIp (Debugging purposes)
resource "aws_security_group_rule" "asg_tcp_myip" {
  type              = "ingress"
  from_port         = var.app_port
  to_port           = var.app_port
  protocol          = "tcp"
  cidr_blocks       = ["${local.my_ip}/32"]
  security_group_id = aws_security_group.asg.id
}

# SSH access
resource "aws_security_group_rule" "asg_ssh_myip" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${local.my_ip}/32"]
  security_group_id = aws_security_group.asg.id
}

######################################################################
## Launch instances
######################################################################

resource "aws_launch_template" "asg" {
  name_prefix   = "${var.app_name}-asg"
  image_id      = local.app_ami_id
  instance_type = var.app_instance_type
  key_name      = var.app_key_name
  vpc_security_group_ids = [
    aws_security_group.asg.id
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.app_name}-asg"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name_prefix = "${var.app_name}-"
  desired_capacity = var.app_desired_size
  max_size         = var.app_max_size
  min_size         = var.app_min_size

  launch_template {
    id      = aws_launch_template.asg.id
    version = "$Latest"
  }

  vpc_zone_identifier = local.app_subnets

  depends_on = [aws_lb.alb]

  target_group_arns = [
    aws_lb_target_group.alb_tg_http.arn
  ]
}
