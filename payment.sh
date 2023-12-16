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

dnf install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "Python installation"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app  &>> $LOGFILE
VALIDATE $? "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip
VALIDATE $? "Downloading payment.zip"

cd /app  &>> $LOGFILE
VALIDATE $? "Changing to app directory"

unzip /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "Unzipping the file"

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "Installing the dependencies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "Copy the payment service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reload"

systemctl enable payment  &>> $LOGFILE
VALIDATE $? "Enabling the payment"

systemctl start payment &>> $LOGFILE
VALIDATE $? "Starting the payment"
