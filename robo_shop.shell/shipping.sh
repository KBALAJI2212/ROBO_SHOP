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


#Downloads and Installs Shipping Service
echo -e "${Y}Downloading and Installing Shipping Package${N}"
useradd roboshop
mkdir /app
cd /app
yum install wget unzip maven -y
wget https://roboshop-builds.s3.amazonaws.com/shipping.zip
unzip -o /app/shipping.zip
mvn clean package
mv target/shipping-1.0.jar shipping.jar
validation $? "Downloading and Installing Shipping Package"


# configures a systemd service called "shipping", which runs a Java application as a background service
echo -e "${Y}Configuring Shipping Service${N}"
shipping_config="/etc/systemd/system/shipping.service"

cat<<EOF >$shipping_config
[Unit]
Description=Shipping Service

[Service]
User=roboshop

#####use local host for Cart Service and MySQL if hosted on same server, if not change "localhost" to IP address or DNS name.#####

Environment=CART_ENDPOINT=localhost:8080
Environment=DB_HOST=localhost
ExecStart=/bin/java -jar /app/shipping.jar
SyslogIdentifier=shipping

[Install]
WantedBy=multi-user.target
EOF
validation $? "Configuring Shipping Service"


#Installs MySQL client and loads Shipping Schema into MySQL Server
echo -e "${Y}Loading Shipping Schema into MySQL Server${N}"
dnf install mysql -y

#####use local host for MySQL if hosted on same server, if not change "localhost" to IP address or DNS name.#####

mysql -h localhost -uroot -pRoboShop@1 < /app/schema/shipping.sql 
validation $? "Loading Shipping Schema into MySQL Server"


#Starts Shipping Service
echo -e "${Y}Starting Shipping Service${N}"
systemctl daemon-reload
systemctl enable shipping
systemctl start shipping
validation $? "Starting Shipping Service"