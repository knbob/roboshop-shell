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

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "Enabling nginx"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "Removing default html"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "Downlading code"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "Changing directory"

unzip /tmp/web.zip &>> $LOGFILE
VALIDATE $? "Unzipping code"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf  &>> $LOGFILE
VALIDATE $? "Copy robosho config"

systemctl restart nginx  &>> $LOGFILE
VALIDATE $? "Restarting nginx"