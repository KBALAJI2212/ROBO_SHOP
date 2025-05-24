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
