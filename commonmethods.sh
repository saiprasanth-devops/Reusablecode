#!/bin/bash


startingstep(){
user_id=$(id -u)
logfolder="/var/log/roboshop"
logfile=$0
mkdir -p "$logfolder"
logfullpath=""${logfolder}"/"${logfile}".log"
touch "$logfullpath"
echo "------------------starting the execution run-----------------------------"         &>> "$logfullpath"  
echo ""$logfolder""    &>> "$logfullpath" 
echo ""$logfile""    &>> "$logfullpath"
echo ""$logfullpath""  &>> "$logfullpath"
echo ""$logfullpath""  | tee -a  "$logfullpath"




if [ "$user_id" -eq 0 ];
then
echo "user is sudo user"
validate $? "user is sudo user"      
else
echo "please proceed with sudo user"
exit 1
fi

}

#check the exit status for all the steps
validate(){

    status_check=$1
    if [ "$status_check" -eq 0 ];
    then 
    echo "$(date) [INFO] "${2}" --------- success : PASS "   &>> "$logfullpath" 
  
    else
    echo "$(date) [INFO] "${2}" --------- Failed : Failed "   &>> "$logfullpath" 
    fi
}

#mongodb installation function
mongodbsetup(){

    #Set up the MongoDB repo file:
cp mogodb /etc/yum.repos.d/mongo.repo       
validate $? "Copy the repo file to yum repos"
dnf install mongodb-org -y    &>> "$logfullpath" 
validate $? "install the monogdb-org with directly y"
systemctl enable mongod      &>> "$logfullpath" 
validate $? "enable the mongod"
systemctl start mongod       &>> "$logfullpath" 
validate $? "start the mongod"        &>> "$logfullpath" 
# sed will not look whether the 127 is present or not in the second run if the command execute it is 0
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf    
validate $? "change the port from 127 to 0.0.0.0"        &>> "$logfullpath" 
systemctl restart mongod
validate $? "restart the mongod"        &>> "$logfullpath"
systemctl status mongod 
validate $? "status check for the mongod"        &>> "$logfullpath"

}

#redis installation function

redissetup(){


    dnf module disable redis -y    &>> "$logfullpath" 
validate $? "module disable redis with directly y"
dnf module enable redis:7 -y   &>> "$logfullpath" 
validate $? "module enable redis:7 -y"
dnf install redis -y           &>> "$logfullpath" 
validate $? "install redis -y"
sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf    
validate $? "change the port from 127 to 0.0.0.0"        &>> "$logfullpath" 
sed -i 's/protected-mode yes/protected-mode no/' /etc/redis.conf    
validate $? "sed -i 's/protected-mode yes/protected-mode no/' /etc/redis.conf"        &>> "$logfullpath" 
systemctl enable redis    &>> "$logfullpath" 
validate $? "systemctl enable redis"
systemctl start redis    &>> "$logfullpath" 
validate $? "systemctl start redis"
systemctl status redis 
validate $? "status check for the redis"        &>> "$logfullpath"

}

#mysql installation function

mysqlsetup(){

    dnf module enable mysql:8.4 -y   &>> "$logfullpath" 
validate $? "dnf module enable mysql:8.4 -y"
dnf install mysql-server -y          &>> "$logfullpath" 
systemctl enable mysqld    &>> "$logfullpath" 
validate $? "systemctl enable mysqld"
systemctl start mysqld    &>> "$logfullpath" 
validate $? "systemctl start mysqld"
passwordset=$(mysql_secure_installation --set-root-pass RoboShop@1)
echo ""$passwordset""
#for the text contains we need to use [[==]]

if [[ "$passwordset" == *"Password already set"* ]];
then 
echo "password is already set "    &>> "$logfullpath"
elif [ "$?" -eq 0 ];
then 
echo "password is setnow username is root"    &>> "$logfullpath"
else
echo "error"
exit 1
fi
systemctl restart mysqld
validate $? "systemctl restart the  mysqld"
systemctl status mysqld
validate $? "systemctl status the  mysqld"
}


#rabbitmq installation function

rabitmqsetup(){

    #rabbitmq
cp rabbitmq /etc/yum.repos.d/rabbitmq.repo
validate $? "repo has been added to the repo file"
dnf list erlang -y        &>> "$logfullpath"
modulevalidate $? "dnf list erlang"
dnf list rabbitmq-server -y &>> "$logfullpath"
modulevalidate $? "dnf list rabbitmq-server"
dnf module list erlang -y   &>> "$logfullpath"
modulevalidate $? "dnf module list erlang"

dnf module list rannitmq-server -y &>> "$logfullpath"

modulevalidate $? "dnf module list rannitmq-server"

dnf install erlang -y    &>> "$logfullpath"
validate $? "dnf install erlang"

dnf install rabbitmq-server -y     &>> "$logfullpath"
validate $? "dnf install rabbitmq-server -y"

systemctl enable rabbitmq-server     &>> "$logfullpath"
validate $? "systemctl enable rabbitmq-server"

systemctl start rabbitmq-server        | tee -a  "$logfullpath"
validate $? "systemctl start rabbitmq-server"

systemctl status rabbitmq-server        | tee -a  "$logfullpath"
validate $? "systemctl status rabbitmq-server"



#now we need t0 create the 
rabbitmqctl add_user roboshop roboshop123     &>>  "$logfullpath"
if [ "$?" -eq 0 ];
then 
    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

else 
echo "user is already present so skipped"    &>> "$logfullpath"
fi

systemctl restart rabbitmq-server     &>> "$logfullpath"
validate $? "systemctl restart rabbitmq-server"

systemctl status rabbitmq-server        | tee -a  "$logfullpath"
validate $? "systemctl status rabbitmq-server"
}


#customized service for the module
modulevalidate(){
     modulestatus=$1

     if [ "$modulestatus" -eq 0 ];
     then 
     echo ""$2" [INFO] module consists-----SUCCESS"   &>> "$logfullpath" 
     elif [ "$modulestatus" -ne 0 ];
     then 
     echo ""$2" skipping "    &>> "$logfullpath" 
     fi      

}

#nodejs installation function

nodejs_setup(){
    servicename=$1
    servicefilename=$2
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
cp "${servicefilename}" /etc/systemd/system/catalogue.service            &>> "$logfullpath" 
validate $? "npm should be installed"              &>> "$logfullpath"

systemctl status "${service}"   &>> "$logfullpath"
validate $? "systemctl status "${service}""
systemctl reload "${service}"    &>> "$logfullpath"
validate $? "systemctl reload "${service}""
systemctl enable "${service}"     &>> "$logfullpath"
validate $? "systemctl enable "${service}""
systemctl start "${service}"     &>> "$logfullpath"
validate $? "systemctl start "${service}""

}


get_unziprealcode(){
   codeservicepath=$1

    mkdir -p /app
validate $? "create the app folder in the /"

curl -L -o /tmp/"${codeservicepath}".zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/"${codeservicepath}"-v4.zip
validate $? "download the folder into the /tmp folder"

cd /app       &>> "$logfullpath" 
validate $? "go to app folder"
rm -rf /app         &>> "$logfullpath" 
validate $? "remove the files in the /app folder"
mkdir -p /app
validate $? "create the app folder in the /"
cd /app 
unzip /tmp/"${codeservicepath}".zip      &>> "$logfullpath" 
validate $? "and unzip it"    
}


