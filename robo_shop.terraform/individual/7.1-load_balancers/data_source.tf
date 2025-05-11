data "aws_ssm_parameter" "roboshop_vpc_id" {
  name = "/roboshop/vpc_id"
}

data "aws_ssm_parameter" "public_subnet_id" {
  count = 2
  name  = "/roboshop/public_subnet_id_${count.index + 1}"
}

data "aws_ssm_parameter" "private_subnet_id" {
  count = 2
  name  = "/roboshop/private_subnet_id_${count.index + 1}"
}

data "aws_ssm_parameter" "public_sg_id" {
  name = "/roboshop/public_sg_id"
}

data "aws_ssm_parameter" "app_lb_sg_id" {
  name = "/roboshop/app_lb_sg_id"
}

data "aws_ssm_parameter" "private_sg_id" {
  name = "/roboshop/private_sg_id"
}

data "aws_ssm_parameter" "hosted_zone_cert_arn" {
  name = "/roboshop/hosted_zone_cert_arn"
}
