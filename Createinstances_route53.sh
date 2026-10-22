#!/bin/bash

image_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
security_group_ids="sg-02a3f89bd2dcb78b1"
#instance_name="general"
hosted_zone_id="Z063293532TA5U290WZK9"
record_name="godeploy.online"

source ./Securitygroups_Allservices.sh

instanceid_derive(){
    instancename=$1
 if [[ "$instancename" == *"mysql"* ]];
 then 
  updatesecuritygroup "$mysql_securitygroups"
  elif [[ "$instancename" == *"mongodb"* ]];
 then 
  updatesecuritygroup "$mongodb_securitygroups"
  elif [[ "$instancename" == *"catalogue"* ]];
 then 
  updatesecuritygroup "$catalogue_securitygroups"
 elif [[ "$insinstancenametance" == *"rabbitmq"* ]];
 then 
  updatesecuritygroup "$rabbitmq_securitygroups"
  elif [[ "$instancename" == *"dispatch"* ]];
 then 
  updatesecuritygroup "$dispatch_securitygroups"
 elif [[ "$instancename" == *"shipping"* ]];
 then 
  updatesecuritygroup "$shipping_securitygroups"
  elif [[ "$instancename" == *"user"* ]];
 then 
  updatesecuritygroup "$user_securitygroups"

    elif [[ "$instancename" == *"redis"* ]];
 then 
  updatesecuritygroup "$redis_securitygroups"

    elif [[ "$instancename" == *"cart"* ]];
 then 
  updatesecuritygroup "$cart_securitygroups"

    elif [[ "$instancename" == *"frontend"* ]];
 then 
  updatesecuritygroup "$frontend_securitygroups"

    elif [[ "$instancename" == *"payment"* ]];
 then 
  updatesecuritygroup "$payment_securitygroups"
  else 
  echo "data is not found"
  fi
}


updatesecuritygroup(){
securitygroup=$1
 instanceid=$(aws ec2 run-instances \
    --image-id "$image_id" \
    --instance-type "$instance_type" \
    --security-groups "$securitygroup" \
     --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-"${instancename}"}]" \
    --query "Instances[0].InstanceId" \
    --output text)
}

for instancename in "$@"
do
echo "$instancename"
instanceid=$(instanceid_derive "$instancename")
echo "$instanceid"
if [ "${instancename}" == "frontend" ] || [ "$instancename" = "FRONTEND" ];
then 
publicipaddress=$(publicip "$instanceid")
route53_frontend="$record_name"
echo ""$route53_frontend""
update_route53 "$route53_frontend" "$publicipaddress"
else
privateipaddress=$(privateip "$instanceid")
route53_all="$instanceid"."$record_name"
update_route53 "$route53_all" "$privateipaddress"
fi
done

privateip(){
   instanceid=$1
privateip=$(aws ec2 describe-instances \
    --instance-ids "$instanceid" \
    --query "Reservations[*].Instances[*].PrivateIpAddress" \
    --output text })

}

publicip(){
 instanceid=$1
publicip=$(aws ec2 describe-instances \
    --instance-ids "$instanceid" \
    --query "Reservations[*].Instances[*].PublicIpAddress" \
    --output text })


}
update_route53(){

   ipvalue=$1
   route53=$2
   aws route53 change-resource-record-sets \
    --hosted-zone-id "${hosted_zone_id}" \
    --change-batch '{
      "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": ""${route53}"",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [{"Value": ""${ipvalue}""}]
        }
      }]
    }'

}