#!/bin/bash

SG_ID="sg-07366cc6e801b5354"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z09562662SLZPT00M9LMW"
DOMAIN_NAME="88sdaws.fun"

for instance in $@      # @-> we can send multiple arguments like mongodb,catalogue....etc
do
    INSTANCE_ID=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text )

    if [ $instance == "frontend" ]; then
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text
        )
        RECORD_NAME="$DOMAIN_NAME"   # 88sdaws.fun
        else
            IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
            )
            RECORD_NAME="$instance.$DOMAIN_NAME"   # mongodb.88sdaws.fun

        fi
        echo "IP address: $IP"

        aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE_ID \
        --change-batch '
        {
        "Comment": "Updating record ",
        "Changes": [
         {
            "Action": "UPSERT",
            "ResourceRecordSet": {
            "Name": "'$RECORD_NAME'",
            "Type": "A",
            "TTL": 1,
            "ResourceRecords": [
             {
                "Value": "'$IP'"
            }
            ]
        }
        }
    ]
    }
        '
    echo "record updated for $instance"
done



    
