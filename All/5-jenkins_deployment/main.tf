resource "aws_launch_template" "jenkins_deployment_lt" {
  name                   = "jenkins-deployment-launchtemplate"
  image_id               = data.aws_ssm_parameter.roboshop_ami_id.value
  instance_type          = "t3.medium"
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
      volume_size = 25
    }
  }


  user_data = base64encode(<<EOF
#!/bin/bash
systemctl start docker
mkdir /home/balaji/jenkins_data
sudo chown -R 1000:1000 /home/balaji/jenkins_data
cd /home/balaji
git clone https://github.com/KBALAJI2212/ROBO_SHOP.git
docker compose -f /home/balaji/ROBO_SHOP/robo_shop.jenkins/docker-compose.yaml up -d
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "jenkins_deployment_instance"
    }
  }
}


resource "aws_lb_target_group" "jenkins_deployment_tg" {

  name     = "jenkins-deployment-target-group"
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
    Name = "jenkins_deployment_target_group"
  }
}

resource "aws_autoscaling_group" "jenkins_deployment_asg" {
  name                      = "jenkins-deployment-auto-scaling-group"
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  vpc_zone_identifier       = [data.aws_ssm_parameter.public_subnet_id[0].value, data.aws_ssm_parameter.public_subnet_id[1].value]
  health_check_type         = "ELB"
  health_check_grace_period = 900
  default_cooldown          = 300

  target_group_arns = [aws_lb_target_group.jenkins_deployment_tg.arn, aws_lb_target_group.jenkins_tg.arn, aws_lb_target_group.grafana_tg.arn, aws_lb_target_group.cadvisor_tg.arn, aws_lb_target_group.node_exporter_tg.arn, aws_lb_target_group.prometheus_tg.arn]


  launch_template {
    id      = aws_launch_template.jenkins_deployment_lt.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "jenkins_deployment_listener_rule" {
  listener_arn = data.aws_ssm_parameter.web_lb_https_listener_arn.value

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_deployment_tg.arn
  }

  condition {
    host_header {
      values = ["jenkins.balaji.website"]
    }
  }

  tags = {
    Name = "jenkins_deployment_listener_rule"
  }
}
resource "aws_route53_record" "jenkins_deployment_web_record" {

  zone_id = "Z04307862A5Z0E82KA5RX"
  name    = "jenkins.balaji.website"
  type    = "A"

  alias {
    name                   = data.aws_ssm_parameter.web_lb_dns.value
    zone_id                = data.aws_ssm_parameter.web_lb_zone_id.value
    evaluate_target_health = true
  }
}



#Jenkins Service
resource "aws_lb_target_group" "jenkins_tg" {

  name     = "jenkins-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.roboshop_vpc_id.value

  health_check {
    path                = "/health/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "jenkins_target_group"
  }
}
resource "aws_route53_record" "jenkins_record" {

  zone_id = "Z04307862A5Z0E82KA5RX"
  name    = "jenkins-web.balaji.website"
  type    = "A"

  alias {
    name                   = data.aws_ssm_parameter.web_lb_dns.value
    zone_id                = data.aws_ssm_parameter.web_lb_zone_id.value
    evaluate_target_health = true
  }
}
resource "aws_lb_listener_rule" "jenkins_listener_rule" {
  listener_arn = data.aws_ssm_parameter.web_lb_https_listener_arn.value

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }

  condition {
    host_header {
      values = ["jenkins-web.balaji.website"]
    }
  }

  tags = {
    Name = "jenkins_listener_rule"
  }
}


#Grafana Service
resource "aws_lb_target_group" "grafana_tg" {

  name     = "grafana-target-group"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.roboshop_vpc_id.value

  health_check {
    path                = "/health/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "grafana_target_group"
  }
}
resource "aws_route53_record" "grafana_record" {

  zone_id = "Z04307862A5Z0E82KA5RX"
  name    = "grafana.balaji.website"
  type    = "A"

  alias {
    name                   = data.aws_ssm_parameter.web_lb_dns.value
    zone_id                = data.aws_ssm_parameter.web_lb_zone_id.value
    evaluate_target_health = true
  }
}
resource "aws_lb_listener_rule" "grafana_listener_rule" {
  listener_arn = data.aws_ssm_parameter.web_lb_https_listener_arn.value

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_tg.arn
  }

  condition {
    host_header {
      values = ["grafana.balaji.website"]
    }
  }

  tags = {
    Name = "grafana_listener_rule"
  }
}



#cAdvisor Service
resource "aws_lb_target_group" "cadvisor_tg" {

  name     = "cadvisor-target-group"
  port     = 8082
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.roboshop_vpc_id.value

  health_check {
    path                = "/health/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "cadvisor_target_group"
  }
}
resource "aws_route53_record" "cadvisor_record" {

  zone_id = "Z04307862A5Z0E82KA5RX"
  name    = "cadvisor.balaji.website"
  type    = "A"

  alias {
    name                   = data.aws_ssm_parameter.web_lb_dns.value
    zone_id                = data.aws_ssm_parameter.web_lb_zone_id.value
    evaluate_target_health = true
  }
}
resource "aws_lb_listener_rule" "cadvisor_listener_rule" {
  listener_arn = data.aws_ssm_parameter.web_lb_https_listener_arn.value

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cadvisor_tg.arn
  }

  condition {
    host_header {
      values = ["cadvisor.balaji.website"]
    }
  }

  tags = {
    Name = "cadvisor_listener_rule"
  }
}


#Node-Exporter Service
resource "aws_lb_target_group" "node_exporter_tg" {

  name     = "node-exporter-target-group"
  port     = 8083
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.roboshop_vpc_id.value

  health_check {
    path                = "/health/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "node_exporter_target_group"
  }
}
resource "aws_route53_record" "node_exporter_record" {

  zone_id = "Z04307862A5Z0E82KA5RX"
  name    = "node.balaji.website"
  type    = "A"

  alias {
    name                   = data.aws_ssm_parameter.web_lb_dns.value
    zone_id                = data.aws_ssm_parameter.web_lb_zone_id.value
    evaluate_target_health = true
  }
}
resource "aws_lb_listener_rule" "node_exporter_listener_rule" {
  listener_arn = data.aws_ssm_parameter.web_lb_https_listener_arn.value

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.node_exporter_tg.arn
  }

  condition {
    host_header {
      values = ["node.balaji.website"]
    }
  }

  tags = {
    Name = "node_exporter_listener_rule"
  }
}


#Prometheus Service
resource "aws_lb_target_group" "prometheus_tg" {

  name     = "prometheus-target-group"
  port     = 8084
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.roboshop_vpc_id.value

  health_check {
    path                = "/health/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "prometheus_target_group"
  }
}
resource "aws_route53_record" "prometheus_record" {

  zone_id = "Z04307862A5Z0E82KA5RX"
  name    = "prometheus.balaji.website"
  type    = "A"

  alias {
    name                   = data.aws_ssm_parameter.web_lb_dns.value
    zone_id                = data.aws_ssm_parameter.web_lb_zone_id.value
    evaluate_target_health = true
  }
}
resource "aws_lb_listener_rule" "prometheus_listener_rule" {
  listener_arn = data.aws_ssm_parameter.web_lb_https_listener_arn.value

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus_tg.arn
  }

  condition {
    host_header {
      values = ["prometheus.balaji.website"]
    }
  }

  tags = {
    Name = "prometheus_listener_rule"
  }
}
