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

module "mongodb" {
  source     = "../individual/3-mongodb"
  depends_on = [module.network]
}

module "redis" {
  source     = "../individual/4-redis"
  depends_on = [module.mongodb]
}

module "mysql" {
  source     = "../individual/5-mysql"
  depends_on = [module.redis]
}

module "rabbitmq" {
  source     = "../individual/6-rabbitmq"
  depends_on = [module.mysql]
}

module "acm" {
  source     = "../individual/7-ACM"
  depends_on = [module.rabbitmq]
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



