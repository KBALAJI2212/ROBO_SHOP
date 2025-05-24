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

data "aws_ssm_parameter" "catalogue_tg_arn" {
  name = "/roboshop/catalogue_tg_arn"
}

data "aws_ssm_parameter" "mongodb_ip" {
  name = "/roboshop/mongodb_ip"
}
