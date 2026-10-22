#!/bin/bash

image_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
security_group_ids="sg-02a3f89bd2dcb78b1"
#instance_name="general"
hosted_zone_id="Z063293532TA5U290WZK9"
record_name="godeploy.online"

source ./Securitygroups_Allservices.sh


for instancename in "$@"
do


echo "$instancename"

instanceid=$(instanceid_derive "$instancename")

echo "$instanceid"


done



instanceid_derive(){


    instancename=$1
 if [[ "$instance" == *"mysql"* ]];
 then 
  updatesecuritygroup "$mysql_securitygroups"
  elif [[ "$instance" == *"mongodb"* ]];
 then 
  updatesecuritygroup "$mongodb_securitygroups"
  elif [[ "$instance" == *"catalogue"* ]];
 then 
  updatesecuritygroup "$catalogue_securitygroups"
 elif [[ "$instance" == *"rabbitmq"* ]];
 then 
  updatesecuritygroup "$rabbitmq_securitygroups"
  elif [[ "$instance" == *"dispatch"* ]];
 then 
  updatesecuritygroup "$dispatch_securitygroups"
 elif [[ "$instance" == *"shipping"* ]];
 then 
  updatesecuritygroup "$shipping_securitygroups"
  elif [[ "$instance" == *"user"* ]];
 then 
  updatesecuritygroup "$user_securitygroups"

    elif [[ "$instance" == *"redis"* ]];
 then 
  updatesecuritygroup "$redis_securitygroups"

    elif [[ "$instance" == *"cart"* ]];
 then 
  updatesecuritygroup "$cart_securitygroups"

    elif [[ "$instance" == *"frontend"* ]];
 then 
  updatesecuritygroup "$frontend_securitygroups"

    elif [[ "$instance" == *"payment"* ]];
 then 
  updatesecuritygroup "$payment_securitygroups"
  fi
}


updatesecuritygroup(){

securitygroup=$1
 instanceid=$(aws ec2 run-instances \
    --image-id "$image_id" \
    --instance-type "$instance_type" \
    --security-groups "$securitygroup" \
     --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-"${instance}"}]" \
    --query "Instances[0].InstanceId" \
    --output text)
}