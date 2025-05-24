resource "aws_launch_template" "cart_lt" {
  name          = "cart-server-launchtemplate"
  image_id      = data.aws_ssm_parameter.roboshop_ami_id.value
  instance_type = "t3.micro"


  instance_market_options {
    market_type = "spot"
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 8
    }
  }

  vpc_security_group_ids = [data.aws_ssm_parameter.private_sg_id.value]

  user_data = base64encode(templatefile("../userdata/cart.sh", { redis_ip = data.aws_ssm_parameter.redis_ip.value, app_lb_dns = data.aws_ssm_parameter.app_lb_dns.value }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Cart_instance"
    }
  }
}
