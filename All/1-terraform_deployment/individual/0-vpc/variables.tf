variable "db_sub_cidr" {
  default = "10.0.1.0/25"
}

variable "private_sub_cidr" {
  type    = list(string)
  default = ["10.0.2.0/25", "10.0.2.128/25"]
}

variable "public_sub_cidr" {
  type    = list(string)
  default = ["10.0.3.0/25", "10.0.3.128/25"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]

}

