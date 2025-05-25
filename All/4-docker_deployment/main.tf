resource "aws_launch_template" "docker_deployment_lt" {
  name                   = "docker-deployment-launchtemplate"
  image_id               = data.aws_ssm_parameter.roboshop_ami_id.value
  instance_type          = "t3.small"
  vpc_security_group_ids = [data.aws_ssm_parameter.public_sg_id.value]

  instance_market_options {
    market_type = "spot"

    spot_options {
      spot_instance_type             = "one-time"
      instance_interruption_behavior = "terminate"
    }
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 15
    }
  }

  user_data = base64encode(<<EOF
#!/bin/bash
cd /home/balaji
git clone https://github.com/KBALAJI2212/ROBO_SHOP.git
systemctl start docker
docker compose -f /home/balaji/ROBO_SHOP/robo_shop.docker/docker-compose.yaml up -d
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "docker_deployment_instance"
    }
  }
}


resource "aws_lb_target_group" "docker_deployment_tg" {

  name     = "docker-deployment-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.roboshop_vpc_id.value

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "docker_deployment_target_group"
  }
}

resource "aws_autoscaling_group" "docker_deployment_asg" {
  name                      = "docker-deployment-auto-scaling-group"
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  vpc_zone_identifier       = [data.aws_ssm_parameter.public_subnet_id[0].value, data.aws_ssm_parameter.public_subnet_id[1].value]
  health_check_type         = "ELB"
  health_check_grace_period = 900
  default_cooldown          = 300

  target_group_arns = [aws_lb_target_group.docker_deployment_tg.arn]


  launch_template {
    id      = aws_launch_template.docker_deployment_lt.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "docker_deployment_listener_rule" {
  listener_arn = data.aws_ssm_parameter.web_lb_https_listener_arn.value

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.docker_deployment_tg.arn
  }

  condition {
    host_header {
      values = ["docker.balaji.website"]
    }
  }

  tags = {
    Name = "docker_deployment_listener_rule"
  }
}

resource "aws_route53_record" "docker_deployment_web_record" {

  zone_id = "Z04307862A5Z0E82KA5RX"
  name    = "docker.balaji.website"
  type    = "A"

  alias {
    name                   = data.aws_ssm_parameter.web_lb_dns.value
    zone_id                = data.aws_ssm_parameter.web_lb_zone_id.value
    evaluate_target_health = true
  }
}
