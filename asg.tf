######################################################################
## Security groups
######################################################################

resource "aws_security_group" "api" {
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
resource "aws_security_group_rule" "api_tcp_80_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.api.id
}

# Configuration of the firewall - Instances <-> MyIp (Debugging purposes)
resource "aws_security_group_rule" "api_tcp_80_myip" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["${local.my_ip}/32"]
  security_group_id = aws_security_group.api.id
}

######################################################################
## Launch instances
######################################################################

resource "aws_launch_template" "api" {
  name_prefix   = "${var.app_name}-asg"
  image_id      = local.app_ami_id
  instance_type = var.app_instance_type
  key_name      = var.app_key_name
  vpc_security_group_ids = [
    local.ops_sg,
    aws_security_group.api.id
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.app_name}-asg"
    }
  }
}

resource "aws_autoscaling_group" "api" {
  desired_capacity = 1
  max_size         = 1
  min_size         = 1

  launch_template {
    id      = aws_launch_template.api.id
    version = "$Latest"
  }

  vpc_zone_identifier = local.app_subnets

  depends_on = [aws_lb.alb]

  target_group_arns = [
    aws_lb_target_group.alb_tg_http.arn
  ]
}
