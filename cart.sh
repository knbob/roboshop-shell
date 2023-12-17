#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling nodejs:18 version"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Nodejs installation"

id roboshop
if [ $? == 0 ]
then
echo " user already exists "
else
 useradd roboshop &>> $LOGFILE
 VALIDATE $? "roboshop user creation"
 fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "creating app folder"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "Downloading code"

cd /app &>> $LOGFILE
VALIDATE $? "Changing to app folder"

unzip /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "Unzipping the code"

npm install &>> $LOGFILE
VALIDATE $? "Installing the dependencies"

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copying cart service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reload"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "Enabling cart"

systemctl start cart &>> $LOGFILE
VALIDATE $? "Starting cart"