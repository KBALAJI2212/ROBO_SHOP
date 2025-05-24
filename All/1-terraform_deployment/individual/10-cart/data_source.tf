data "aws_ssm_parameter" "roboshop_ami_id" {

  name = "/roboshop/ami_id"

}

data "aws_ssm_parameter" "private_sg_id" {
  name = "/roboshop/private_sg_id"
}

data "aws_ssm_parameter" "private_subnet_id" {
  count = 2
  name  = "/roboshop/private_subnet_id_${count.index + 1}"
}

data "aws_ssm_parameter" "cart_tg_arn" {
  name = "/roboshop/cart_tg_arn"
}

data "aws_ssm_parameter" "redis_ip" {
  name = "/roboshop/redis_ip"
}

data "aws_ssm_parameter" "app_lb_dns" {
  name = "/roboshop/app_lb_dns"

}
