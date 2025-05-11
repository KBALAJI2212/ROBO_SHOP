data "aws_ssm_parameter" "roboshop_ami_id" {
  name = "/roboshop/ami_id"
}

data "aws_ssm_parameter" "public_subnet_id" {
  count = 2
  name  = "/roboshop/public_subnet_id_${count.index + 1}"
}

data "aws_ssm_parameter" "public_sg_id" {
  name = "/roboshop/public_sg_id"
}

data "aws_ssm_parameter" "private_sg_id" {
  name = "/roboshop/private_sg_id"
}

data "aws_ssm_parameter" "databases_sg_id" {
  name = "/roboshop/databases_sg_id"
}
