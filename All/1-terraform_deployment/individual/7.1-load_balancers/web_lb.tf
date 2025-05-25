resource "aws_lb" "web_lb" {
  name               = "web-lb"
  load_balancer_type = "application"
  subnets            = [data.aws_ssm_parameter.public_subnet_id[0].value, data.aws_ssm_parameter.public_subnet_id[1].value]
  security_groups    = [data.aws_ssm_parameter.public_sg_id.value]
  internal           = false

  access_logs {
    bucket  = "load-balancers-logs5"
    enabled = true
    prefix  = "web_lb_logs"
  }

  depends_on = [aws_s3_bucket.load_balancers_logs_bucket]

  tags = {
    Name = "roboshop_web_load_balancer"
  }

}

resource "aws_lb_listener" "web_lb_http_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name = "web_lb_http_listener"
  }
}

resource "aws_lb_listener" "web_lb_https_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  certificate_arn = data.aws_ssm_parameter.hosted_zone_cert_arn.value

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Requested Host Header did not match any Service."
      status_code  = "404"
    }
  }

  tags = {
    Name = "web_lb_https_listener"
  }
}

resource "aws_lb_target_group" "web_tg" {

  name     = "web-target-group"
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
    Name = "web_target_group"
  }

}


resource "aws_lb_listener_rule" "terraform_deployment_listener_rule" {
  listener_arn = aws_lb_listener.web_lb_https_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

  condition {
    host_header {
      values = ["terraform.balaji.website"]
    }
  }

  tags = {
    Name = "terraform_deployment_listener_rule"
  }
}


#DNS RECORD

resource "aws_route53_record" "terraform_deployment_web_record" {
  zone_id = "Z04307862A5Z0E82KA5RX"
  name    = "terraform.balaji.website"
  type    = "A"

  alias {
    name                   = aws_lb.web_lb.dns_name
    zone_id                = aws_lb.web_lb.zone_id
    evaluate_target_health = true
  }
}
