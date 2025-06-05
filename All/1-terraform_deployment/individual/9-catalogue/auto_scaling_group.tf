resource "aws_autoscaling_group" "catalogue_asg" {
  name                      = "catalogue-server-auto-scaling-group"
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  vpc_zone_identifier       = [data.aws_ssm_parameter.private_subnet_id[0].value, data.aws_ssm_parameter.private_subnet_id[1].value]
  health_check_type         = "ELB"
  health_check_grace_period = 600
  default_cooldown          = 300

  target_group_arns = [data.aws_ssm_parameter.catalogue_tg_arn.value]

  launch_template {
    id      = aws_launch_template.catalogue_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "catalogue_scale_policy" {
  name                   = "catalogue_scale_policy"
  autoscaling_group_name = aws_autoscaling_group.catalogue_asg.name

  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 85.0
  }
}
