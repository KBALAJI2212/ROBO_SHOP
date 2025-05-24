data "aws_ssm_parameter" "roboshop_ami_id" {

  name = "/roboshop/ami_id"

}

data "aws_ssm_parameter" "databases_subnet_id" {
  name = "/roboshop/databases_subnet_id"
}

data "aws_ssm_parameter" "databases_sg_id" {
  name = "/roboshop/databases_sg_id"
}
