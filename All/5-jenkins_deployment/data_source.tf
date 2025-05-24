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


data "aws_instances" "jenkins_deployment_instance_public_ip" {

  filter {
    name   = "tag:Name"
    values = ["jenkins_deployment_instance"]
  }
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}
