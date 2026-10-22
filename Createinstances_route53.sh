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
  instanceid=$(updatesecuritygroup "$mysql_securitygroups")
   echo "$instanceid"
    #updatesecuritygroup "$catalogue_securitygroups"
  elif [[ "$instancename" == *"mongodb"* ]];
 then 
 instanceid=$(updatesecuritygroup "$mongodb_securitygroups")
   echo "$instanceid"
     elif [[ "$instancename" == *"catalogue"* ]];
 then 
 instanceid=$(updatesecuritygroup "$catalogue_securitygroups")
   echo "$instanceid"
    elif [[ "$instancename" == *"rabbitmq"* ]];
 then 
 instanceid=$(updatesecuritygroup "$rabbitmq_securitygroups")
   echo "$instanceid"
     elif [[ "$instancename" == *"dispatch"* ]];
 then 
 instanceid=$(updatesecuritygroup "$dispatch_securitygroups")
   echo "$instanceid"
    elif [[ "$instancename" == *"shipping"* ]];
 then 
 instanceid=$(updatesecuritygroup "$shipping_securitygroups")
   echo "$instanceid"
     elif [[ "$instancename" == *"user"* ]];
 then 
 instanceid=$(updatesecuritygroup "$mysql_securitygroups")
   echo "$instanceid"
    elif [[ "$instancename" == *"redis"* ]];
 then 
 instanceid=$(updatesecuritygroup "$user_securitygroups")
   echo "$instanceid"
    elif [[ "$instancename" == *"cart"* ]];
 then 
 instanceid=$(updatesecuritygroup "$cart_securitygroups")
   echo "$instanceid"
    elif [[ "$instancename" == *"frontend"* ]];
 then 
 instanceid=$(updatesecuritygroup "$frontend_securitygroups")
   echo "$instanceid"
    elif [[ "$instancename" == *"payment"* ]];
 then 
 instanceid=$(updatesecuritygroup "$payment_securitygroups")
   echo "$instanceid" 
    else 
  echo "data is not found"
  exit 1
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


    echo ""$instanceid""
}

privateip(){
   instanceid1=$1
privateip=$(aws ec2 describe-instances \
    --instance-ids "$instanceid1" \
    --query "Reservations[*].Instances[*].PrivateIpAddress" \
    --output text )

    echo "$privateip"

}

publicip(){
 instanceid2=$1
publicip=$(aws ec2 describe-instances \
    --instance-ids "$instanceid2" \
    --query "Reservations[*].Instances[*].PublicIpAddress" \
    --output text )

    echo "$publicip"

}
update_route53(){
   route53=$1
   ipvalue=$2
   aws route53 change-resource-record-sets \
    --hosted-zone-id "${hosted_zone_id}" \
    --change-batch '{
      "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'${route53}'",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [{"Value": "'${ipvalue}'"}]
        }
      }]
    }'

}

for instancename in "$@"
do
echo "$instancename"
instanceid=$(instanceid_derive "$instancename")
echo "enters in the for loop"
echo "$instanceid"
if [ "${instancename}" == "frontend" ] || [ "$instancename" = "FRONTEND" ];
then 
publicipaddress=$(publicip "$instanceid")
route53_frontend="$record_name"
echo ""$route53_frontend""
update_route53 "$route53_frontend" "$publicipaddress"
else
privateipaddress=$(privateip "$instanceid")
echo "$privateipaddress"
route53_all="$instancename"".""$record_name"
update_route53 "$route53_all" "$privateipaddress"
fi
done

