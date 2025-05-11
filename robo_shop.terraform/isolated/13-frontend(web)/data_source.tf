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

data "aws_ssm_parameter" "web_tg_arn" {
  name = "/roboshop/web_tg_arn"
}

data "aws_ssm_parameter" "app_lb_dns" {
  name = "/roboshop/app_lb_dns"

}

