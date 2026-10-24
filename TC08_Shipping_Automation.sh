#!/bin/bash

service=shipping
inputservicefilename=shippingservicefile

source ./Securitygroups_Allservices.sh
source ./commonmethods.sh

mavensetup(){

dnf module disable maven -y   &>> "$logfullpath" 
modulevalidate $? "dnf list nodejs -y"

dnf module enable maven:"${mavenversion}" -y
modulevalidate $? "dnf module enable maven:"${mavenversion}" -y"

dnf module list maven -y      &>> "$logfullpath" 
modulevalidate $? "dnf module list maven -y"

dnf install maven java-25-openjdk-devel -y    &>> "$logfullpath" 
validate $? "dnf install maven java-25-openjdk-devel -y"

alternatives --set java "${javapath}"      &>> "$logfullpath" 
validate $? "alternatives --set java"

echo "${javapath}-------------------"        &>> "$logfullpath" 

echo "export JAVA_HOME="${javapath}""   > /etc/profile.d/java.sh    &>> "$logfullpath" 
validate $? "export JAVA_HOME="${javapath}""

source /etc/profile.d/java.sh     &>> "$logfullpath" 
validate $? "source /etc/profile.d/java.sh"

echo "$JAVA_HOME"   &>> "$logfullpath" 

get_unziprealcode "$service"

roboshopid=$(id roboshop)
if [ "$?" -eq 0 ];
then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop    &>> "$logfullpath" 
else
echo "user is already present and skipping him to create"
fi

cd /app
validate $? "cd /app"

mvn clean package
validate $? "cd /app"

mv target/shipping.jar shipping.jar
validate $? "mv target/shipping.jar shipping.jar"


dnf install mysql -y
validate $? "dnf install mysql -y"

count=$(mysql -h "mysql.godeploy.online" -u root -pRoboShop@1 -N -B -e "SELECT COUNT(*) FROM cities.cities;" &>> "$logfullpath"  )
if [ -z "$count" ] || [ "$count" -eq 0 ]; then
    mysql -h "mysql.godeploy.online" -uroot -pRoboShop@1 < /app/db/master-data.sql
    validate $? "Loading shipping data"
else
    echo " skipping since data is already present" &>> "$logfullpath"
fi


mysql -h "mysql.godeploy.online" -uroot -pRoboShop@1 < /app/db/app-user.sql   &>> "$logfullpath"
validate $? "user is craeted "

cp "${inputservicefilename}" /etc/systemd/system/"${service}".service
validate $? "copied filed"

#systemctl daemon-reload
systemctl restart "${service}"     &>> "$logfullpath"
validate $? "systemctl restart "${service}""

systemctl enable "${service}"        &>> "$logfullpath"
validate $? "systemctl enable "${service}""
 
systemctl enable "${service}"            &>> "$logfullpath"
validate $? "systemctl enable "${service}""

systemctl status "${service}"              &>> "$logfullpath"
validate $? "systemctl status "${service}""


}

startingstep
mavensetup  










