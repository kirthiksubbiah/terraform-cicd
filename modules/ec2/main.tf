# App Tier
# Launch Template for App Tier
resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "${var.project_prefix}-app-lt-"
  image_id      = "ami-0b4b56913872844b2"
  instance_type = "t2.micro"

  iam_instance_profile {
    name = var.aws_iam_instance_profile
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.private_app_sg_id]
  }

  user_data = base64encode(templatefile("${path.module}/scripts/app-userdata.sh", {
    project_prefix = var.project_prefix
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_prefix}-app-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_prefix}-app-launch-template"
  }
}

# Target Group for Internal Load Balancer
resource "aws_lb_target_group" "app_target_group" {
  name     = "${var.project_prefix}-app-target-group"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 3
    healthy_threshold   = 3
    port                = 4000
  }

  tags = {
    Name = "${var.project_prefix}-app-target-group"
  }
}

# Internal Load Balancer
resource "aws_lb" "internal_app_lb" {
  name                        = "${var.project_prefix}-internal-app-lb"
  internal                    = true
  load_balancer_type          = "application"
  security_groups             = [var.internal_lb_sg_id]
  subnets                     = var.private_app_subnet_ids
  enable_deletion_protection  = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.project_prefix}-internal-app-lb"
  }
}

resource "aws_lb_listener" "internal_app_listener" {
  load_balancer_arn = aws_lb.internal_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }

  tags = {
    Name = "${var.project_prefix}-internal-app-listener"
  }
}

# Auto Scaling Group for App Tier
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 3
  name                      = "${var.project_prefix}-app-asg"
  vpc_zone_identifier       = var.private_app_subnet_ids

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [
    aws_lb_target_group.app_target_group.arn
  ]

  health_check_type           = "ELB"
  health_check_grace_period  = 300
  force_delete                = true
  wait_for_capacity_timeout   = "0"

  tag {
    key                 = "Name"
    value               = "${var.project_prefix}-app-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Web Tier
# Launch Template for Web Tier
resource "aws_launch_template" "web_launch_template" {
  name_prefix   = "${var.project_prefix}-web-lt-"
  image_id      = "ami-0b4b56913872844b2"
  instance_type = "t2.micro"

  iam_instance_profile {
    name = var.aws_iam_instance_profile
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.public_web_sg_id]
  }

  user_data = base64encode(templatefile("${path.module}/scripts/web-userdata.sh", {
    project_prefix = var.project_prefix
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_prefix}-web-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_prefix}-web-launch-template"
  }
}

# Target Group for External Load Balancer
resource "aws_lb_target_group" "web_target_group" {
  name     = "${var.project_prefix}-web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 3
    healthy_threshold   = 3
    port                = 80
  }

  tags = {
    Name = "${var.project_prefix}-web-target-group"
  }
}

# External Load Balancer
resource "aws_lb" "external_web_lb" {
  name                        = "${var.project_prefix}-external-web-lb"
  internal                    = false
  load_balancer_type          = "application"
  security_groups             = [var.public_lb_sg_id]
  subnets                     = var.public_web_subnet_ids
  enable_deletion_protection  = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.project_prefix}-external-web-lb"
  }
}

resource "aws_lb_listener" "external_web_listener" {
  load_balancer_arn = aws_lb.external_web_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }

  tags = {
    Name = "${var.project_prefix}-external-web-listener"
  }
}

# Auto Scaling Group for Web Tier
resource "aws_autoscaling_group" "web_asg" {
  depends_on = [aws_autoscaling_group.app_asg]
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 3
  name                      = "${var.project_prefix}-web-asg"
  vpc_zone_identifier       = var.public_web_subnet_ids

  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [
    aws_lb_target_group.web_target_group.arn
  ]

  health_check_type           = "ELB"
  health_check_grace_period  = 300
  force_delete                = true
  wait_for_capacity_timeout   = "0"

  tag {
    key                 = "Name"
    value               = "${var.project_prefix}-web-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}