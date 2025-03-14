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


#Complete Python Prerequisites
echo -e "${Y}Preparing Prerequisites${N}"
yum install python3 python3-pip -y
yum install python3-devel -y
pip3.6 install uwsgi
validation $? "Preparing Prerequisites"


#Downloads and Installs Payment Service
echo -e "${Y}Installing Payment Service${N}"
useradd roboshop
mkdir -p /app/payment
cd /app/payment
wget https://buildbucket5.s3.us-east-1.amazonaws.com/RoboShop/payment.zip
unzip -o payment.zip
pip3.6 install -r requirements.txt
validation $? "Installing Payment Service"


# configures a systemd service called "payment", which runs a Python application as a background service
echo -e "${Y}Configuring Payment Service${N}"
payment_config="/etc/systemd/system/payment.service"

cat<<EOF >$payment_config
[Unit]
Description=Payment Service

[Service]
User=root
WorkingDirectory=/app/payment

#####use "localhost" for Cart Service ,User Service and RabbitMQ if hosted on same server, if not change "localhost" to IP address or DNS name.#####

Environment=CART_HOST=localhost
Environment=CART_PORT=8083
Environment=USER_HOST=localhost
Environment=USER_PORT=8081
Environment=AMQP_HOST=localhost
Environment=AMQP_USER=roboshop
Environment=AMQP_PASS=RoboShop@1

ExecStart=/usr/local/bin/uwsgi --ini payment.ini
ExecStop=/bin/kill -9 \$MAINPID
SyslogIdentifier=payment

[Install]
WantedBy=multi-user.target
EOF

validation $? "Configuring Payment Service"


#Starts Payment Service
echo -e "${Y}Starting Payment Service${N}"
systemctl daemon-reload
systemctl enable payment
systemctl start payment
validation $? "Starting Payment Service"