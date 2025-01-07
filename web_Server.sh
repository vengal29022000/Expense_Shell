#!/bin/bash
user_id=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [ $? -ne 0 ]
    then
        echo -e "$1 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$1 ... $G SUCCESS $N"
    fi
}
#To check user is having the access or not.
if [ $user_id -ne 0 ]
then
    echo -e "$R ERROR:$N You need Sudo acess to execute this script"
    exit 1
fi

dnf install nginx -y &>>LOG_FILE_NAME
VALIDATE "Installing nginx"

systemctl enable nginx &>>LOG_FILE_NAME
VALIDATE "Enabling nginx"

systemctl start nginx &>>LOG_FILE_NAME
VALIDATE "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>LOG_FILE_NAME
VALIDATE "Removing Default html code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE "Downloading Frontend"

cd /usr/share/nginx/html &>>LOG_FILE_NAME
VALIDATE "/usr/share/nginx/html"

unzip /tmp/frontend.zip &>>LOG_FILE_NAME
VALIDATE "Unzipping Frontend"

cp /home/ec2-user/EXPENSE_SHELL/expense.conf /etc/nginx/default.d/expense.conf &>>LOG_FILE_NAME
VALIDATE "copying expense.conf file to /etc/nginx/default.d/expense.conf"

systemctl restart nginx &>>LOG_FILE_NAME
VALIDATE "restarting nginx"