#!/bin/bash
while [ $(aws guardduty list-detectors --region ${target_region} --output table | wc -l) -le 3 ]; do  
    echo waiting;
    sleep 1; 
done

while [ $(aws ec2 describe-instances --region ${target_region} --filters "Name=tag:Type,Values=Malicious Instance" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].PublicIpAddress" | tr -d \\\") == "null" ]; 
    do sleep 1; 
done

TARGET_IP=$(aws ec2 describe-instances --region ${target_region} --filters "Name=tag:Type,Values=Malicious Instance" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].PublicIpAddress" | tr -d \\\")
while true; do 
    curl $$TARGET_IP; 
    sleep 15; 
done