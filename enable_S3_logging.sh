#!/bin/bash

##############################################################
# Author : Ravi
# Date   : 16-02-2024
# This script will list all the buckets and enable s3 logging
#
##############################################################
set -e 
###################################
# Get a list of all S3 bucket names
###################################
echo "********************************************************************"
echo "             Printing the S3 bucket List"  
echo "********************************************************************"

aws s3api list-buckets --query 'Buckets[].Name' --output table

bucket_names=$(aws s3api list-buckets --query 'Buckets[].Name' --output text)

###################################
# Loop through each bucket
###################################
echo "********************************************************************"
echo "            Checking for Log Enable and Enabling the Logs"  
echo "********************************************************************"
for bucket_name in $bucket_names; do
    echo $bucket_name
    # Check if logging is enabled for the bucket

    logging_status=$(aws s3api get-bucket-logging --bucket "$bucket_name" --query 'LoggingEnabled')

    if [ "$logging_status" == "null" ]; then
        echo "Logging is not enabled for the bucket '$bucket_name'. Enabling now..."
        echo "********************************************************************"

        # Check if put-bucket-acl is enabled, if not, enable it
        acl_status=$(aws s3api get-bucket-acl --bucket "$bucket_name" --query 'Grants[?Grantee.URI==`http://acs.amazonaws.com/groups/s3/LogDelivery`].Permission' --output text)

        if [ "$acl_status" ]; then
            echo "put-bucket-acl is not enabled for the bucket '$bucket_name'. Enabling now..."
            aws s3api put-bucket-acl --bucket "$bucket_name" --grant-write URI=http://acs.amazonaws.com/groups/s3/LogDelivery --grant-read-acp URI=http://acs.amazonaws.com/groups/s3/LogDelivery
            echo "put-bucket-acl has been enabled for the bucket '$bucket_name'."
            echo "********************************************************************"
        fi

        # Specify the target bucket to store access logs
        target_bucket=$bucket_name

        # Specify the prefix for the log files
        log_prefix="logs/"

        # Enable logging for the bucket
        aws s3api put-bucket-logging --bucket "$bucket_name" --bucket-logging-status "{\"LoggingEnabled\": {\"TargetBucket\": \"$target_bucket\", \"TargetPrefix\": \"$log_prefix\"}}"

        echo "Logging has been enabled for the bucket '$bucket_name'."
        echo "********************************************************************"
    else
        echo "Logging is already enabled for the bucket '$bucket_name'."
        echo "********************************************************************"
    fi
done
