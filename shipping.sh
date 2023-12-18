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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "Installing maven"

id roboshop &>> $LOGFILE
if [ $? == 0 ]
then
echo -e "Used already existing...$Y skipping $N"
else
useradd roboshop &>> $LOGFILE
VALIDATE $? "Adding user roboshop"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "Downloading code"

cd /app &>> $LOGFILE
VALIDATE $? "Changing to app directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "Unzipping the file"

mvn clean package &>> $LOGFILE
VALIDATE $? "Installing dependencies"

mv app/target/shipping-1.0.jar /app/target/shipping.jar
VALIDATE $? "Shipping file renaming"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "Copying shipping service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reload"

systemctl enable shipping  &>> $LOGFILE
VALIDATE $? "Enabling shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "Starting shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "Installing mysql"

mysql -h mysql.knbob.online -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $LOGFILE
VALIDATE $? "Loading schema into mysql"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "Restart shipping"