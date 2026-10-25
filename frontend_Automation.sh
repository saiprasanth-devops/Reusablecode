#!/bin/bash

service=frontend
configfilefrontend=frontendservicefile
source ./commonmethods.sh

startingstep

frontendsetup(){

dnf list nginx -y           &>> "$logfullpath"
modulevalidate $? "dnf list nginx -y"   

dnf module list ngix -y            &>> "$logfullpath"
modulevalidate $? "dnf module list ngix -y"

dnf module disable nginx -y            &>> "$logfullpath"
modulevalidate $? "dnf module disable nginx -y"

dnf module enable nginx:1.26 -y          &>> "$logfullpath"
modulevalidate $? "dnf module enable nginx:1.26 -y"

dnf install nginx -y             &>> "$logfullpath"
validate $? "dnf install nginx -y"

rm -rf /usr/share/nginx/html/*                   
validate $? "dnf install nginx -y"

unzip

cp "${configfilefrontend}" /etc/nginx/default.d/roboshop.conf             
validate $? "dnf install nginx -y"

systemctl restart nginx          &>> "$logfullpath"
validate $? "systemctl restart nginx"

systemctl start nginx        &>> "$logfullpath"
validate $? "systemctl start nginx"

systemctl status nginx           &>> "$logfullpath"
validate $? "systemctl status nginx"

}

unzip(){
 
rm -f /tmp/"${service}".zip
 curl -L -o /tmp/"${service}".zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/"${service}"-v4.zip

cd /usr/share/nginx/html
unzip /tmp/"${service}".zip


}
