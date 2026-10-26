#!/bin/bash
service=payment
inputservicefilename=dispatchservicefile

source ./Securitygroups_Allservices.sh
source ./commonmethods.sh


startingstep
setup_dispatch(){


    dnf install golang -y
validate $? "    dnf install golang -y"

    roboshopid=$(id roboshop)
if [ "$?" -eq 0 ];
then
echo "user is already present and skipping him to create"
else
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop    &>> "$logfullpath" 
fi
get_unziprealcode "${service}"

cd /app
go build -o dispatch
validate $? "buid diapatch"

path=$(dirname "$(find / -name 'dispatchservicefile' 2>/dev/null | head -n 1)")
echo "path ----------->"${path}""
cp "${path}""/""${inputservicefilename}" /etc/systemd/system/"${service}".service
validate $? "copied filed"

systemctl daemon-reload            &>> "$logfullpath" 
validate $? "buid diapatch"

systemctl enable dispatch         &>> "$logfullpath" 
validate $? "buid diapatch"

systemctl start dispatch         &>> "$logfullpath" 
validate $? "buid diapatch"


systemctl status dispatch
validate $? "systemctl status dispatch"

journaltctl -u dispatch -f    | tee -a 



}
