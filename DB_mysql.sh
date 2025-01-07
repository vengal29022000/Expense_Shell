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
echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME      # Printing the script started time in the log file

dnf install mysql-server -y &>>$LOG_FILE_NAME &>>LOG_FILE_NAME
VALIDATE "Installing MySql Server"

systemctl enable mysqld &>>LOG_FILE_NAME
VALIDATE "Enabling MySql Server"

systemctl start mysqld &>>LOG_FILE_NAME
VALIDATE "Starting MySql Server"


mysql_secure_installation --set-root-pass ExpenseApp@1 &>>LOG_FILE_NAME
VALIDATE "Setting Root Password"




