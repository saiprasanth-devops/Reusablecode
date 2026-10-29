#!/bin/bash


# aws ec2 describe-instances \
#     --filters "Name=tag:Name,Values=*roboshop*" "Name=instance-state-name,Values=running,stopped" \
#     --query "Reservations[].Instances[].InstanceId" \
#     --output text


# instancename=$(aws ec2 describe-instances \
# --filters "Name=instance-state-name,Values=running" \
# --query "Reservations[*].Instances[*].InstanceId" \
# --output text)


instances=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text)