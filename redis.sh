#!/bin/bash

ID=$(id -u)
R="e\[31m"
G="e\[32m"
Y="e\[33m"
N="e\[0m"

TIME=$(date +%F:%H:%M:%S)

LOGFILE="/tmp/$0-$TIME.log"

echo "Script execution started at $TIME" &>> $LOGFILE

VALIDATE(){
    if [ $? == 0 ]
    then
    echo -e " $2.............$G SUCCESS $N"
    else
    echo -e " $2.............$R Failed $N"
    fi
}

if [ $ID == 0 ]
then
echo " Logged in as root user "
else
echo " Run the script with root access "
exit 1
fi

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
VALIDATE $? "Installing rpm"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? "Enabling remi"

dnf install redis -y &>> $LOGFILE
VALIDATE $? "Redis Installation"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOGFILE
VALIDATE $? "Remote access to Redis"

systemctl enable redis &>> $LOGFILE
VALIDATE $? "Enabling redis"

systemctl start redis &>> $LOGFILE
VALIDATE $? "Starting redis"