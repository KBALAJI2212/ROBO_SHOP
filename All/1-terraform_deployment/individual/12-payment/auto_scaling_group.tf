resource "aws_autoscaling_group" "payment_asg" {
  name                      = "payment-server-auto-scaling-group"
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 2
  vpc_zone_identifier       = [data.aws_ssm_parameter.private_subnet_id[0].value, data.aws_ssm_parameter.private_subnet_id[1].value]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  default_cooldown          = 300

  target_group_arns = [data.aws_ssm_parameter.payment_tg_arn.value]

  launch_template {
    id      = aws_launch_template.payment_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "payment_scale_policy" {
  name                   = "payment_scale_policy"
  autoscaling_group_name = aws_autoscaling_group.payment_asg.name

  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 85.0
  }
}


resource "aws_autoscaling_lifecycle_hook" "payment_launch_delay" {
  name                   = "payment_launch_delay"
  autoscaling_group_name = aws_autoscaling_group.payment_asg.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
  default_result         = "CONTINUE"
  heartbeat_timeout      = 360
}
