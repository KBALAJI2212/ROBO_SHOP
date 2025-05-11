resource "aws_autoscaling_group" "user_asg" {
  name                      = "user-server-auto-scaling-group"
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 2
  vpc_zone_identifier       = [data.aws_ssm_parameter.private_subnet_id[0].value, data.aws_ssm_parameter.private_subnet_id[1].value]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  default_cooldown          = 300

  target_group_arns = [data.aws_ssm_parameter.user_tg_arn.value]

  launch_template {
    id      = aws_launch_template.user_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "user_scale_policy" {
  name                   = "user_scale_policy"
  autoscaling_group_name = aws_autoscaling_group.user_asg.name

  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 85.0
  }
}


resource "aws_autoscaling_lifecycle_hook" "user_launch_delay" {
  name                   = "user_launch_delay"
  autoscaling_group_name = aws_autoscaling_group.user_asg.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
  default_result         = "CONTINUE"
  heartbeat_timeout      = 360
}
