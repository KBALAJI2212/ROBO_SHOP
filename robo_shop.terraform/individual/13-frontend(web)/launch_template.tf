resource "aws_launch_template" "web_lt" {
  name          = "web-server-launchtemplate"
  image_id      = data.aws_ssm_parameter.roboshop_ami_id.value
  instance_type = "t2.micro"


  instance_market_options {
    market_type = "spot"
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 8
    }
  }

  vpc_security_group_ids = [data.aws_ssm_parameter.public_sg_id.value]

  user_data = base64encode(templatefile("../userdata/web.sh", { app_lb_dns = data.aws_ssm_parameter.app_lb_dns.value }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Web_instance"
    }
  }
}
