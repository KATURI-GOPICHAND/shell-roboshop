#!/bin/bash

SG_ID="sg-07366cc6e801b5354"
AMI-ID="ami-0220d79f3f480ecf5"

for instance in $@      # @-> we can send multiple arguments like mongodb,catalogue....etc
do
    Instnce_id= $( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text )

    if [ $Instnce_id == "frontend"]; then
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $Instnce_id \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text

        )
        else
            IP=$(
            aws ec2 describe-instances \
            --instance-ids $Instnce_id \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
            )
        fi

done



    
