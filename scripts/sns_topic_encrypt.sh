#!/bin/bash

##############################################################
# Author : Ravi
# Date   : 16-02-2024
# This script will list all the buckets and enable s3 logging
#
##############################################################
set -e 
region="ap-south-1"
kms_arn="arn:aws:kms:ap-south-1:871794273757:key/2d53457f-f9e0-463b-a631-b389abba5b92"
###################################
# Get a list of all S3 bucket names
###################################
echo "*************************************************"
echo "            List SNS Topics"         
echo "*************************************************"
aws sns list-topics --region $region --query 'Topics[]' --output table
topic_arns=$(aws sns list-topics --region $region --query 'Topics[].TopicArn' --output text)
#topic_arns= aws sns list-topics --region $region
for topic_arn in $topic_arns; do
    echo "*************************************************"
    echo "          Setting SNS topic attributes"         
    echo "*************************************************"
    aws sns set-topic-attributes --region $region --topic-arn $topic_arn --attribute-name KmsMasterKeyId --attribute-value $kms_arn

# to check whether the commands execute succesfull or not
if [ $? -eq 0 ]; then
        echo "************************************************"
        echo "Encryption enabled for SNS topic: $topic_arns"
        echo "************************************************"
    else
        echo "************************************************"
        echo "Failed to enable encryption for SNS topic: $topic_arns"
        echo "************************************************"
    fi

done
