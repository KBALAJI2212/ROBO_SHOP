resource "aws_autoscaling_group" "cart_asg" {
  name                      = "cart-server-auto-scaling-group"
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 2
  vpc_zone_identifier       = [data.aws_ssm_parameter.private_subnet_id[0].value, data.aws_ssm_parameter.private_subnet_id[1].value]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  default_cooldown          = 300

  target_group_arns = [data.aws_ssm_parameter.cart_tg_arn.value]

  launch_template {
    id      = aws_launch_template.cart_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "cart_scale_policy" {
  name                   = "cart_scale_policy"
  autoscaling_group_name = aws_autoscaling_group.cart_asg.name

  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 85.0
  }
}


resource "aws_autoscaling_lifecycle_hook" "cart_launch_delay" {
  name                   = "cart_launch_delay"
  autoscaling_group_name = aws_autoscaling_group.cart_asg.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
  default_result         = "CONTINUE"
  heartbeat_timeout      = 360
}
