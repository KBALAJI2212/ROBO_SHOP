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