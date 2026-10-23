#!/bin/bash


aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=*roboshop*" "Name=instance-state-name,Values=running,stopped" \
    --query "Reservations[].Instances[].InstanceId" \
    --output text
