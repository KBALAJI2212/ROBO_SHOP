#!/bin/bash


#Colors for temrinal

#RED
R="\e[31m"                
#GREEN
G="\e[32m"
#YELLOW
Y="\e[33m"
#NORMAL
N="\e[0m"


validation(){
    if [ $1 -eq 0 ];
    then 
        echo -e "${G}$2 is successful${N}"
    else 
        echo -e "${R}$2 has Failed${N}"
        exit 1;
    fi
}

#checks for Root permissions
if [ $(id -u) -ne 0 ];    
then
    echo "Please run this script as Root User"
    exit 1;
else
    true;
fi


#Completes Prerequisites for RabbitMQ
echo -e "${Y}Preparing Prerequisites${N}"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash
validation $? "Preparing Prerequisites"


#Installs and Starts RabbitMQ
echo -e "${Y}Installing and Starting RabbitMQ${N}"
dnf install rabbitmq-server -y
systemctl enable rabbitmq-server
systemctl start rabbitmq-server
validation $? "Installing and Starting RabbitMQ"


#Creates a user and assigns permissions
echo -e "${Y}Configuring RabbitMQ${N}"
rabbitmqctl add_user roboshop RoboShop@1
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
validation $? "Configuring RabbitMQ"