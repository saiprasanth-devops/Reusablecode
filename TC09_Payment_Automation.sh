#!/bin/bash


service=payment
inputservicefilename=paymentservicefile

source ./Securitygroups_Allservices.sh
source ./commonmethods.sh

startingstep
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

cd /app                 &>> "$logfullpath" 
validate $? "download the folder into the /tmp folder"

python3.14 -m venv /app/.venv               &>> "$logfullpath" 
validate $? "download the folder into the /tmp folder"

/app/.venv/bin/pip install -r requirements.txt              &>> "$logfullpath" 
validate $? "download the folder into the /tmp folder"

path=$(dirname "$(find / -name 'paymentservicefile' 2>/dev/null | head -n 1)")
echo "path ----------->"${path}""
cp "${path}""/""${inputservicefilename}" /etc/systemd/system/"${service}".service
validate $? "copied filed"

systemctl daemon-reload                &>> "$logfullpath" 
validate $? "systemctl daemon-reload"

systemctl restart payment              &>> "$logfullpath" 
validate $? "systemctl restart payment"

systemctl enable  payment                    &>> "$logfullpath" 
validate $? "systemctl enable  payment"

systemctl start payment         &>> "$logfullpath" 
validate $? "systemctl start payment"

systemctl status payment             &>> "$logfullpath" 
validate $? "systemctl status payment"





}
pythonsetup 

