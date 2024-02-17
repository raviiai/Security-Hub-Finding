#!/bin/bash

##############################################################
# Author : Ravi
# Date   : 17-02-2024
# 2.1.2 Ensure S3 Bucket Policy is set to deny HTTP requests
#
##############################################################

###################################
# Get a list of all S3 bucket names
###################################
echo "******************************************"
buckets=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)

for bucket in $buckets; do
    echo "*********************************"
    aws s3api get-bucket-policy --bucket "$bucket" --query Policy --output json
    echo "*********************************"

    aws s3api put-bucket-policy \
        --bucket "$bucket" \
        --policy '{
        "Version": "2012-10-17",
        "Id": "cc-secure-transport-bucket-policy",
        "Statement": [
            {
            "Effect": "Deny",
            "Principal": { "AWS": "*" },
            "Action": "s3:*",
            "Condition": {
                "Bool": { "aws:SecureTransport": false }
            },
            "Resource":"arn:aws:s3:::'"$bucket"'/*"
            }
        ]
        }'
done
