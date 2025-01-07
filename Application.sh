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

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE "Disabling NodeJs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE "Enabling NodeJs:20"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE "Installing NodeJs"

id expense
if [$? -ne 0 ]
then
    useradd expense &>>$LOG_FILE_NAME
    VALIDATE "Adding User"
else
    echo -e "$R user is already created $N....$Y skipping $N"
fi
mkdir /app &>>$LOG_FILE_NAME
VALIDATE "/app"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2. &>>LOG_FILE_NAME
VALIDATE "Downloading Backend..."

cd /app &>>$LOG_FILE_NAME               
VALIDATE "/app"
cd /app
unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE "Unzipping Backend"

npm install &>>$LOG_FILE_NAME
VALIDATE "Installing Dependencies"

cp /home/ec2-user/Expense_Shell/backend.service /etc/systemd/system/backend.service &>>LOG_FILE_NAME

#Installing MySQl and Loading the schema
dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE "Installing MySql"

mysql -h mysql.vengalareddy.site -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>LOG_FILE_NAME
VALIDATE "Schema Loading" 

systemctl daemon-reload &>>$LOG_FILE_NAME

systemctl enable backend &>>$LOG_FILE_NAME

systemctl start backend &>>$LOG_FILE_NAME