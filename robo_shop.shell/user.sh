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


#Installs NodeJs version 18
echo -e "${Y}Installing NodeJs${N}"
dnf module disable nodejs -y
dnf module enable nodejs:18 -y
dnf install nodejs -y
validation $? "Installing NodeJs"


#Downloads User service
echo -e "${Y} Downloading User Service${N}"
useradd roboshop
mkdir -p /app/user
cd /app/user
yum install wget unzip -y
wget https://buildbucket5.s3.us-east-1.amazonaws.com/RoboShop/user.zip
unzip -o user.zip
validation $? "Downloading User Service"


#Installs the NodeJs Application
echo -e "${Y}Installing User Service${N}"
npm install
validation $? "Installing User Service"


# configures a systemd service called "user", which runs a Node.js application as a background service
echo -e "${Y}Configuring User Service${N}"
user_config="/etc/systemd/system/user.service"
cat << EOF >$user_config
[Unit]
Description = User Service
[Service]
User=roboshop
Environment=MONGO=true

#####use local host for Redis and MongoDB if hosted on same server, if not change "localhost" to IP address or DNS name.#####

Environment=REDIS_HOST=localhost
Environment=MONGO_URL="mongodb://localhost:27017/users"
ExecStart=/bin/node /app/user/server.js
SyslogIdentifier=user

[Install]
WantedBy=multi-user.target
EOF
validation $? "Configuring User Service"


#Starts the user Service
echo -e "${Y}Starting User Service${N}"
systemctl daemon-reload
systemctl enable user
systemctl start user
validation $? "Configuring user Service"