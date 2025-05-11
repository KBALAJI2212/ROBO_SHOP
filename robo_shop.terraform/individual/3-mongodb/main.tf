resource "aws_instance" "mongodb" {

  ami                         = data.aws_ssm_parameter.roboshop_ami_id.value
  instance_type               = "t2.micro"
  associate_public_ip_address = false

  subnet_id              = data.aws_ssm_parameter.databases_subnet_id.value
  vpc_security_group_ids = [data.aws_ssm_parameter.databases_sg_id.value]

  root_block_device {
    volume_size = 10
  }
  user_data = file("../userdata/mongodb.sh")

  tags = {
    Name = "Mongodb_instance"
  }
}


resource "aws_ssm_parameter" "mongodb_ip" {
  name  = "/roboshop/mongodb_ip"
  type  = "String"
  value = aws_instance.mongodb.private_ip

}
