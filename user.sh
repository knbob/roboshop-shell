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

id roboshop &>> $LOGFILE
if [ $? == 0 ]
then
echo " user already exists.........$Y SKIPPING $N "
else
 useradd roboshop &>> $LOGFILE
 VALIDATE $? "roboshop user creation"
 fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "creating app folder"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "Downloading code"

cd /app &>> $LOGFILE
VALIDATE $? "Changing to app folder"

unzip /tmp/user.zip &>> $LOGFILE
VALIDATE $? "Unzipping the code"

npm install &>> $LOGFILE
VALIDATE $? "Installing the dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "Copying user service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reload"

systemctl enable user &>> $LOGFILE
VALIDATE $? "Enabling user"

systemctl start user &>> $LOGFILE
VALIDATE $? "Start user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongorepo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installing mongodb client"

mongo --host mongodb.knbob.online </app/schema/user.js &>> $LOGFILE
VALIDATE $? "Loading schema"