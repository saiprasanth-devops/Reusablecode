#!/bin/bash


service=payment
inputservicefilename=paymentservicefile

source ./Securitygroups_Allservices.sh
source ./commonmethods.sh

startingstep
pythonsetup 

pythonsetup(){

dnf module disable python -y   &>> "$logfullpath" 
modulevalidate $? "dnf module disable python -y"

dnf install python3.14 python3.14-pip -y
modulevalidate $? "dnf install python3.14 python3.14-pip -y"


python3.14 --version
modulevalidate $? "python3.14 --version"
roboshopid=$(id roboshop)
if [ "$?" -eq 0 ];
then
echo "user is already present and skipping him to create"
else
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop    &>> "$logfullpath" 
fi
get_unziprealcode "${service}"

cd /app
validate $? "download the folder into the /tmp folder"

python3.14 -m venv /app/.venv
validate $? "download the folder into the /tmp folder"

/app/.venv/bin/pip install -r requirements.txt
validate $? "download the folder into the /tmp folder"

systemctl daemon-reload
validate $? "systemctl daemon-reload"

systemctl restart payment
validate $? "systemctl restart payment"

systemctl enable  payment
validate $? "systemctl enable  payment"

systemctl start payment
validate $? "systemctl start payment"

systemctl status payment
validate $? "systemctl status payment"





}