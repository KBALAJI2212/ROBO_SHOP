data "aws_ssm_parameter" "roboshop_ami_id" {
  name = "/roboshop/ami_id"
}

data "aws_ssm_parameter" "public_sg_id" {
  name = "/roboshop/public_sg_id"
}

data "aws_ssm_parameter" "public_subnet_id" {
  count = 2
  name  = "/roboshop/public_subnet_id_${count.index + 1}"
}

data "aws_ssm_parameter" "roboshop_vpc_id" {
  name = "/roboshop/vpc_id"
}

data "aws_ssm_parameter" "web_lb_https_listener_arn" {
  name = "/roboshop/web_lb_https_listener_arn"
}

data "aws_ssm_parameter" "web_lb_dns" {
  name = "/roboshop/web_lb_dns"
}

data "aws_ssm_parameter" "web_lb_zone_id" {
  name = "/roboshop/web_lb_zone_id"
}
