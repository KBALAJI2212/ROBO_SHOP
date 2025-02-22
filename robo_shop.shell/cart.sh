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
        echo "$2 is ${G}successful${N}"
    else 
        echo "$2 has ${R}Failed${N}"
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


#Downloads Cart service
echo -e "${Y} Downloading Cart Service${N}"
useradd roboshop
mkdir /app
cd /app
wget https://roboshop-builds.s3.amazonaws.com/cart.zip
unzip -o cart.zip
validation $? "Downloading Cart Service"

#Installs the NodeJs Application
echo -e "${Y}Installing Cart Service${N}"
npm install
validation $? "Installing Cart Service"


# configures a systemd service called "cart", which runs a Node.js application as a background service
echo -e "${Y}Configuring Cart Service${N}"
cart_config="/etc/systemd/system/cart.service"
cat << EOF >$cart_config
[Unit]
Description = Cart Service
[Service]
User=roboshop
Environment=REDIS_HOST=redis.balaji.website
Environment=CATALOGUE_HOST=catalogue.balaji.website
Environment=CATALOGUE_PORT=8080
ExecStart=/bin/node /app/server.js
SyslogIdentifier=cart

[Install]
WantedBy=multi-user.target
EOF
validation $? "Configuring Cart Service"


#Starts the Cart Service
echo -e "${Y}Starting Cart Service${N}"
systemctl daemon-reload
systemctl enable cart
systemctl start cart
validation $? "Configuring Cart Service"
