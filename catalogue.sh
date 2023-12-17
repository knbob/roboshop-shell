#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F:%H:%M:%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

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
VALIDATE $? "Disabling current nodejs version"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling nodejs:18 version"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing nodejs:18"

id roboshop &>> $LOGFILE #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip  &>> $LOGFILE
VALIDATE $? "Downloading catalogue application"

cd /app  &>> $LOGFILE
VALIDATE $? "Chaning to directory app"

unzip -o /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "Unzipping file into app"

npm install  &>> $LOGFILE
VALIDATE $? "Installing dependies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "Copying catalgoue service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reload"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "Enabling catalogue"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "Starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copying mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installing mongodb client"

mongo --host mongodb.knbob.online </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "Loading Schema"