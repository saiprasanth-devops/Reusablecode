#!/bin/bash

service=catalogue

source ./commonmethods.sh

startingstep
nodejs_setup "$service"


#nodejs installation function

nodejs_setup(){
    servicename=$1
dnf list nodejs -y    &>> "$logfullpath" 
modulevalidate $? "dnf list nodejs -y"

dnf list available nodejs -y     &>> "$logfullpath" 
modulevalidate $? "dnf list available nodejs -y"

modulelist=$(dnf module list nodejs -y)     &>> "$logfullpath" 
echo ""$modulelist" check we have 24 version"    &>> "$logfullpath" 
modulevalidate $? "dnf module list nodejs -y"
 
dnf module disable nodejs -y                &>> "$logfullpath" 
modulevalidate $? "dnf module disable nodejs -y"

dnf module enable nodejs:24 -y              &>> "$logfullpath" 
modulevalidate $? "dnf module enable nodejs:24 -y"

dnf install nodejs -y              &>> "$logfullpath" 
validate $? "dnf install nodejs -y"

roboshopid=$(id roboshop)
if [ "$?" -eq 0 ];
then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop    &>> "$logfullpath" 
else
echo "user is already present and skipping him to create"
fi

get_unziprealcode "${servicename}"

npm install               &>> "$logfullpath" 
validate $? "npm should be installed"

package=$(ls -l)
echo "$package"        &>> "$logfullpath" 

if [[ "$package" == *"package.json"* ]];
then
echo "we have the dependecies json"
else
echo "doesnot have the depenedency json"
exit 1
fi

filepath=$(realpath $0)
echo "$filepath"
cd /home/ec2-user/Reusablecode/         
cp catalogueservicefile /etc/systemd/system/catalogue.service            &>> "$logfullpath" 
validate $? "npm should be installed"              &>> "$logfullpath"

systemctl status catalogue   &>> "$logfullpath"
validate $? "systemctl status catalogue"
systemctl reload catalogue    &>> "$logfullpath"
validate $? "systemctl reload catalogue"
systemctl enable catalogue     &>> "$logfullpath"
validate $? "systemctl enable catalogue"
systemctl start catalogue     &>> "$logfullpath"
validate $? "systemctl start catalogue"

}