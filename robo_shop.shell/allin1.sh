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

#Checks for Root permissions
if [ $(id -u) -ne 0 ];    
then
    echo "Please run this script as Root User"
    exit 1;
else
    true;
fi

#Creates MongoDB Repo and Installs MongoDB 
echo -e "${Y}Installing MongoDB ${N}"
mongodb_repo="/etc/yum.repos.d/mongo.repo"
cat << EOF >$mongodb_repo
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.2/x86_64/
gpgcheck=0
enabled=1
EOF
dnf install mongodb-org -y
validation $? "Installing MongoDB "

#modifies the MongoDB configuration file to allow remote connections.
echo -e "${Y}Configuring MongoDB${N}"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
sed -i 's/^::1/# ::1/' /etc/hosts
validation $? "Configuring Mongodb"

#Starts and Enables MongoDB
echo -e "${Y}Starting MongoDB${N}"
systemctl enable mongod
systemctl start mongod
validation $? "Starting Mongodb"


#Remi repo is a free and stable YUM repository mainly for the PHP stack
echo -e "${Y}Installing REMI Repository${N}"
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
validation $? "Installing REMI Repository"

#Installs Redis 6.2 Version
echo -e "${Y}Installing Redis${N}"
dnf module enable redis:remi-6.2 -y
dnf install redis -y
validation $? "Installing Redis"

##modifies the Redis configuration file to allow remote connections and starts Redis 
echo -e "${Y}Starting Redis${N}"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
systemctl enable redis
systemctl start redis
validation $? "Starting Redis"


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



#Creates MySQL Repo and Installs MySQL
echo -e "${Y}Installing MySQL${N}"
dnf module disable mysql -y

mysql_repo="/etc/yum.repos.d/mysql.repo"
cat <<EOF >$mysql_repo
[mysql]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/\$basearch/
enabled=1
gpgcheck=0
EOF

dnf install mysql-community-server -y
validation $? "Installing MySQL"

#Starts MySQL
echo -e "${Y}Starting MySQL${N}"
systemctl enable mysqld
systemctl start mysqld
validation $? "Starting MySQL"

#Changes Root User Passsword of MySQL to "RoboShop@1"
echo -e "${Y}Securing MySQL${N}"
temp_pass=$(sudo grep 'temporary password' /var/log/mysqld.log | tail -1 | awk '{print $NF}')
new_pass="RoboShop@1"
mysql --connect-expired-password -u root -p"$temp_pass" -e "SET PASSWORD = PASSWORD('$new_pass');"
mysql -u root -p"$new_pass" -e "CREATE USER 'root'@'%' IDENTIFIED BY '$new_pass';"
mysql -u root -p"$new_pass" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
mysql -u root -p"$new_pass" -e "GRANT PROXY ON ''@'' TO 'root'@'%';"
mysql -u root -p"$new_pass" -e "DROP USER 'root'@'localhost';"
mysql -u root -p"$new_pass" -e "FLUSH PRIVILEGES;"
validation $? "Securing MySQL"




#Services


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
Environment=USER_SERVER_PORT=8081

#####use "localhost" for Redis and MongoDB if hosted on same server, if not change "localhost" to IP address or DNS name.#####

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


#Downloads Cart service
echo -e "${Y} Downloading Cart Service${N}"
useradd roboshop
mkdir -p /app/cart
cd /app/cart
yum install wget unzip -y
wget https://buildbucket5.s3.us-east-1.amazonaws.com/RoboShop/cart.zip
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
Environment=CART_SERVER_PORT=8083

#####use "localhost" for Redis and Catalogue if hosted on same server, if not change "localhost" to IP address or DNS name.#####

Environment=REDIS_HOST=localhost
Environment=CATALOGUE_HOST=localhost
Environment=CATALOGUE_PORT=8082

ExecStart=/bin/node /app/cart/server.js
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



#Downloads Catalogue service
echo -e "${Y} Downloading Catalogue Service${N}"
useradd roboshop
mkdir -p /app/catalogue
cd /app/catalogue
yum install wget unzip -y
wget https://buildbucket5.s3.us-east-1.amazonaws.com/RoboShop/catalogue.zip
unzip -o catalogue.zip
validation $? "Downloading Catalogue Service"

#Installs the NodeJs Application
echo -e "${Y}Installing Catalogue Service${N}"
npm install
# export CATALOGUE_SERVER_PORT=8081
validation $? "Installing Catalogue Service"

# configures a systemd service called "catalogue", which runs a Node.js application as a background service
echo -e "${Y}Configuring Catalogue Service${N}"
catalogue_config="/etc/systemd/system/catalogue.service"
cat << EOF >$catalogue_config
[Unit]
Description = Catalogue Service

[Service]
User=roboshop
Environment=MONGO=true
Environment=CATALOGUE_SERVER_PORT=8082

#####Use "localhost" if MongoDB is hosted on same server, if not change "localhost" to IP address or DNS name.#####

Environment=MONGO_URL="mongodb://localhost:27017/catalogue" 
ExecStart=/bin/node /app/catalogue/server.js
SyslogIdentifier=catalogue

[Install]
WantedBy=multi-user.target
EOF
validation $? "Configuring Catalogue Service"

#Starts the Catalogue Service
echo -e "${Y}Starting Catalogue Service${N}"
systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue
validation $? "Configuring Catalogue Service"

#Creates MongoDB Repo and Installs MongoDB Client
echo -e "${Y}Installing MongoDB Client${N}"
mongodb_repo="/etc/yum.repos.d/mongo.repo"
cat << EOF >$mongodb_repo
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.2/x86_64/
gpgcheck=0
enabled=1
EOF
dnf install mongodb-org-shell -y
validation $? "Installing MongoDB Client"

#Loads Catalogue Schema into MongoDB
echo -e "${Y}Loading Catalogue Schema into MongoDB${N}"
#####use "localhost" if MongoDB is hosted on same server, if not change "localhost" to IP address or DNS name.#####
mongo --host localhost </app/catalogue/schema/catalogue.js
validation $? "Loading Catalogue Schema into MongoDB"



#Downloads and Installs Shipping Service
echo -e "${Y}Downloading and Installing Shipping Package${N}"
useradd roboshop
mkdir -p /app/shipping
cd /app/shipping
yum install wget unzip maven -y
wget https://buildbucket5.s3.us-east-1.amazonaws.com/RoboShop/shipping.zip
unzip -o shipping.zip
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
Environment=SERVER_PORT=8084  

#####use "localhost" for Cart Service and MySQL if hosted on same server, if not change "localhost" to IP address or DNS name.#####

Environment=CART_ENDPOINT=localhost:8083
Environment=DB_HOST=localhost
ExecStart=/bin/java -jar /app/shipping/shipping.jar
SyslogIdentifier=shipping

[Install]
WantedBy=multi-user.target
EOF
validation $? "Configuring Shipping Service"

#Installs MySQL client and loads Shipping Schema into MySQL Server
echo -e "${Y}Loading Shipping Schema into MySQL Server${N}"
dnf install mysql -y

#####use "localhost" for MySQL if hosted on same server, if not change "localhost" to IP address or DNS name.#####

mysql -h localhost -uroot -pRoboShop@1 < /app/shipping/schema/shipping.sql 
validation $? "Loading Shipping Schema into MySQL Server"

#Starts Shipping Service
echo -e "${Y}Starting Shipping Service${N}"
systemctl daemon-reload
systemctl enable shipping
systemctl start shipping
validation $? "Starting Shipping Service"



#Complete Python Prerequisites
echo -e "${Y}Preparing Prerequisites${N}"
yum install python3 python3-pip -y
yum install python3-devel -y
yum groupinstall "Development Tools" -y
pip3.6 install uwsgi
validation $? "Preparing Prerequisites"


#Downloads and Installs Payment Service
echo -e "${Y}Installing Payment Service${N}"
useradd roboshop
mkdir -p /app/payment
cd /app/payment
wget https://buildbucket5.s3.us-east-1.amazonaws.com/RoboShop/payment.zip
unzip -o payment.zip
sed -i "s/socket = 0.0.0.0:8080/socket = 0.0.0.0:8085/" /app/payment/payment.ini
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
Environment=SHOP_PAYMENT_PORT=8085


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



#Installs Nginx
echo -e "${Y}Installing Nginx${N}"         
dnf install nginx -y
validation $? "Installing Nginx"

#replaces default nginx web interface with roboshop web interface
echo -e "${Y}Configuring Web Interface${N}"       
rm -rf /usr/share/nginx/html/*
mkdir /usr/share/nginx/html
cd /usr/share/nginx/html/
yum install wget unzip -y
wget https://buildbucket5.s3.us-east-1.amazonaws.com/RoboShop/web.zip
unzip -o web.zip
rm -f /usr/share/nginx/html/web.zip
sed -i "s/splash.html/shell.html/g" /usr/share/nginx/html/js/controller.js
validation $? "Configuring Web Interface"

#Connects web interface with backend services
echo -e "${Y}Configuring Nginx${N}"
nginx_config="/etc/nginx/default.d/roboshop.conf"
cat << EOF >$nginx_config
proxy_http_version 1.1;
location /images/ {
  expires 5s;
  root   /usr/share/nginx/html;
  try_files \$uri /images/placeholder.jpg;
}

#####use "localhost" for Services if hosted on same server, if not change "localhost" to respective services' IP address or DNS name.#####

 location /api/catalogue/ { proxy_pass http://localhost:8082/; }
 location /api/user/ { proxy_pass http://localhost:8081/; }
 location /api/cart/ { proxy_pass http://localhost:8083/; }
 location /api/shipping/ { proxy_pass http://localhost:8084/; }
 location /api/payment/ { proxy_pass http://localhost:8085/; }

location /health {
  stub_status on;
  access_log off;
}
EOF
validation $? "Configuring Nginx"


#Starts Nginx
echo -e "${Y}Starting Nginx${N}"
systemctl enable nginx
systemctl start nginx
validation $? "Starting Nginx"