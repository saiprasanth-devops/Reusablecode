#!/bin/bash

service=catalogue
inputservicefilename=catalogueservicefile
repofilename=mongofile

source ./commonmethods.sh

startingstep
nodejs_setup "$service" "$inputservicefilename"
#load master data

loadmasterdata(){

cp "$repofilename" /etc/yum.repos.d/mongo.repo
validate $? "repo file copay"        &>> "$logfullpath" 

dnf install mongodb-mongosh -y
validate $? "dnf install mongodb-mongosh -y"        &>> "$logfullpath" 

# mongosh --host mongodb.godeploy.online </app/db/master-data.js
# validate $? "connect the host"        &>> "$logfullpath" 

count=$(mongosh --host mongodb.godeploy.online --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()')
echo "document count------------> "${count}""
validate $? "load the data into mongodb"        &>> "$logfullpath" 


}

loadmasterdata

