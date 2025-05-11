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
        echo -e "$G $2 is Successful $N "
    else
        echo -e "$R $2 has Failed $N "
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
echo -e " $Y Installing Nginx $N "         
dnf install nginx -y
validation $? "Installing Nginx"

#replaces default nginx web interface with roboshop web interface
echo -e " $Y Configuring Web Interface $N "       
rm -rf /usr/share/nginx/html/
mkdir /usr/share/nginx/html
cd /usr/share/nginx/html/
yum install wget unzip -y
wget https://buildbucket5.s3.us-east-1.amazonaws.com/RoboShop/web.zip
unzip -o web.zip
rm -f /usr/share/nginx/html/web.zip
sed -i "s/splash.html/shell.html/g" /usr/share/nginx/html/js/controller.js
validation $? "Configuring Web Interface"

#Connects web interface with backend services
echo -e " $Y Configuring Nginx $N "
nginx_config="/etc/nginx/default.d/roboshop.conf"
cat << EOF >$nginx_config
proxy_http_version 1.1;
location /images/ {
  expires 5s;
  root   /usr/share/nginx/html;
  try_files \$uri /images/placeholder.jpg;
}

#####use "localhost" for Services if hosted on same server, if not change "localhost" to respective services' IP address or DNS name.#####

 location /api/catalogue/ { proxy_pass http://terraform.catalogue.balaji.website:80/; }
 location /api/user/ { proxy_pass http://terraform.user.balaji.website:80/; }
 location /api/cart/ { proxy_pass http://terraform.cart.balaji.website:80/; }
 location /api/shipping/ { proxy_pass http://terraform.shipping.balaji.website:80/; }
 location /api/payment/ { proxy_pass http://terraform.payment.balaji.website:80/; }

location /health {
  stub_status on;
  access_log off;
}
EOF
validation $? "Configuring Nginx"


#Starts Nginx
echo -e " $Y Starting Nginx $N "
systemctl enable nginx
systemctl start nginx
validation $? "Starting Nginx"

