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


#Remi repo is a free and stable YUM repository mainly for the PHP stack
echo -e "${Y}Installing REMI Repository${N}"
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
validation $? "Installing REMI Repository"


#Installs Redis 6.2 Version
echo -e "${Y}Installing Redis${N}"
dnf module enable redis:remi-6.2 -y
dnf install redis -y
validation $? "Installing Redis"

#Configures and starts Redis 
echo -e "${Y}Starting Redis${N}"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
systemctl enable redis
systemctl start redis
validation $? "Starting Redis"