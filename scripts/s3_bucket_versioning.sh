#!/bin/bash

# Get a list of all S3 buckets
echo "***************************************"
echo " List of All s3 Buckets"
echo "***************************************"
aws s3api list-buckets --query 'Buckets[*].Name' --output table

buckets=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)

# Loop through each bucket
for bucket in $buckets; do
    versioning=$(aws s3api get-bucket-versioning --bucket $bucket --query 'Status' --output text)
    if [[ $versioning != "Enabled" ]]; then
        echo "Bucket '$bucket' has versioning not enabled"
        echo "Enabling Now...."
        # Enable versioning for the bucket
        aws s3api put-bucket-versioning --bucket $bucket --versioning-configuration Status=Enabled
        echo "-------------------------------"
        # Check if versioning is successfully enabled
        if [ $? -eq 0 ]; then
            echo "Versioning is enabled for bucket '$bucket'"
            echo "----------------------------------"
        else
            echo "Failed to enable versioning for bucket '$bucket'"
            echo "-----------------------------------------------"
        fi
    fi
done

echo "Versioning Enabled for all Buckets"
echo "-------------------------------------"
