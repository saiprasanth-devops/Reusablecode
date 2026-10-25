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
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop    &>> "$logfullpath" 
else
echo "user is already present and skipping him to create"
fi
get_unziprealcode "${service}"



}