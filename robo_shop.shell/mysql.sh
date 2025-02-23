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
mysql --connect-expired-password -u root -p"$temp_pass" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$new_pass';"
validation $? "Securing MySQL"