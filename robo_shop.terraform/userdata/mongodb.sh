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