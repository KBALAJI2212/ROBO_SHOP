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
        echo -e "$2 is ${G}Successful${N}"
    else
        echo -e "$2 has ${R}Failed${N}"
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

#Installs Nginx
echo "${Y}Installing Nginx${N}"         
dnf install nginx -y
validation $? "Installing Nginx"

#replaces default nginx web interface with roboshop web bjinterface
echo "${Y}Configuring Web Interface${N}"       
rm -rf /usr/share/nginx/html/*
mkdir /usr/share/nginx/html
cd /usr/share/nginx/html/
wget https://roboshop-builds.s3.amazonaws.com/web.zip
unzip -o web.zip
rm -f /usr/share/nginx/html/web.zip
validation $? "Configuring Web Interface"

#Connects web interface with backend services
echo "${Y}Configuring Nginx${N}"
nginx_config="/etc/nginx/default.d/roboshop.conf"
cat << EOF >$nginx_config
proxy_http_version 1.1;
location /images/ {
  expires 5s;
  root   /usr/share/nginx/html;
  try_files \$uri /images/placeholder.jpg;
}
location /api/catalogue/ { proxy_pass http://catalogue.balaji.website:8080/; }
location /api/user/ { proxy_pass http://user.balaji.website:8080/; }
location /api/cart/ { proxy_pass http://cart.balaji.website:8080/; }
location /api/shipping/ { proxy_pass http://shipping.balaji.website:8080/; }
location /api/payment/ { proxy_pass http://payment.balaji.website:8080/; }

location /health {
  stub_status on;
  access_log off;
}
EOF
validation $? "Configuring Nginx"


#Starts Nginx
echo "${Y}Starting Nginx${N}"
systemctl enable nginx
systemctl start nginx
validation $? "Starting Nginx"

