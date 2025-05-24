resource "aws_launch_template" "shell_deployment_lt" {
  name                   = "shell-deployment-launchtemplate"
  image_id               = data.aws_ssm_parameter.roboshop_ami_id.value
  instance_type          = "t3.micro"
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
bash /home/balaji/ROBO_SHOP/robo_shop.shell/allin1.sh
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "shell_deployment_instance"
    }
  }
}



resource "aws_autoscaling_group" "shell_deployment_asg" {
  name                      = "shell-deployment-auto-scaling-group"
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  vpc_zone_identifier       = [data.aws_ssm_parameter.public_subnet_id[0].value, data.aws_ssm_parameter.public_subnet_id[1].value]
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.shell_deployment_lt.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_route53_record" "shell_deployment_record" {

  zone_id = "Z04307862A5Z0E82KA5RX"
  name    = "shell.balaji.website"
  type    = "A"
  ttl     = 300
  records = [data.aws_instances.shell_deployment_instance_public_ip.public_ips[0]]
}
