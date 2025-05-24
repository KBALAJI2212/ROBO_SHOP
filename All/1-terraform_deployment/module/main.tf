module "vpc" {
  source = "../individual/0-vpc"
}

module "security_groups" {
  source     = "../individual/1-security_groups"
  depends_on = [module.vpc]
}

module "nat_instance" {
  source     = "../individual/2-NAT"
  depends_on = [module.security_groups]
}

module "network" {
  source     = "../individual/2.1-network"
  depends_on = [module.nat_instance]
}

module "databases" {
  source     = "../individual/3-databases"
  depends_on = [module.network]
}

module "acm" {
  source     = "../individual/7-ACM"
  depends_on = [module.databases]
}

module "load_balancers" {
  source     = "../individual/7.1-load_balancers"
  depends_on = [module.acm]
}

resource "time_sleep" "app_delay" {
  create_duration = "300s"
  depends_on      = [module.load_balancers]
}

module "user" {
  source     = "../individual/8-user"
  depends_on = [time_sleep.app_delay]
}

module "catalogue" {
  source     = "../individual/9-catalogue"
  depends_on = [module.user]
}

module "cart" {
  source     = "../individual/10-cart"
  depends_on = [module.catalogue]
}

module "shipping" {
  source     = "../individual/11-shipping"
  depends_on = [module.cart]
}

module "payment" {
  source     = "../individual/12-payment"
  depends_on = [module.shipping]
}

resource "time_sleep" "app_delay_2" {
  create_duration = "300s"
  depends_on      = [module.payment]
}

module "web" {
  source     = "../individual/13-frontend(web)"
  depends_on = [time_sleep.app_delay_2]
}




module "shell_deployment" {
  source     = "../../2-shell_deployment/"
  depends_on = [module.web]
}
module "ansible_deployment" {
  source     = "../../3-ansible_deployment/"
  depends_on = [module.shell_deployment]
}
module "docker_deployment" {
  source     = "../../4-docker_deployment/"
  depends_on = [module.ansible_deployment]
}
module "jenkins_deployment" {
  source     = "../../5-jenkins_deployment/"
  depends_on = [module.docker_deployment]
}

