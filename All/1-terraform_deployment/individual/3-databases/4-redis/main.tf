resource "aws_instance" "redis" {

  ami                         = data.aws_ssm_parameter.roboshop_ami_id.value
  instance_type               = "t3.micro"
  associate_public_ip_address = false

  subnet_id              = data.aws_ssm_parameter.databases_subnet_id.value
  vpc_security_group_ids = [data.aws_ssm_parameter.databases_sg_id.value]

  root_block_device {
    volume_size = 10
  }

  user_data = file("../userdata/redis.sh")

  tags = {
    Name = "Redis_instance"
  }
}

resource "aws_ssm_parameter" "redis_ip" {
  name  = "/roboshop/redis_ip"
  type  = "String"
  value = aws_instance.redis.private_ip

}
