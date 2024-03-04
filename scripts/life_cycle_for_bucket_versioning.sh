#!/bin/bash

##############################################################
# Author : Ravi
# Date   : 17-02-2024
# S3.10 S3 buckets with versioining enabled should have lifecycle policies configured
#
##############################################################
# Function to check if versioning is enabled for a given bucket
check_versioning() {
    local bucket_name="$1"
    local versioning_status=$(aws s3api get-bucket-versioning --bucket "$bucket_name" --query "Status" --output text)
    
    if [ "$versioning_status" == "Enabled" ]; then
        return 0
    else
        return 1
    fi
}

# Function to configure lifecycle policy for a bucket
configure_lifecycle_policy() {
    local bucket_name="$1"
    aws s3api put-bucket-lifecycle-configuration --bucket "$bucket_name"  --region us-east-1 --lifecycle-configuration '
    {
        "Rules": [
            {
                "ID": "MoveToGlacierAfter30Days",
                "Status": "Enabled",
                "Prefix": "",
                "Expiration": {
                    "Days": 365
                },
                "Transitions": [
                    {
                        "Days": 30,
                        "StorageClass": "GLACIER"
                    }
                ]
            }
        ]
    }'
}
# Main script
main() {
    # Get list of all buckets
    local buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

    for bucket in $buckets; do
        if check_versioning "$bucket"; then
        echo "****************************************************"
            echo "Configuring lifecycle policy for bucket: $bucket"
            configure_lifecycle_policy "$bucket"
            echo "-----------------------------------"
            echo "  Configured"
        echo "****************************************************"
        else
        echo "****************************************************"
            echo "Versioning is not enabled for bucket: $bucket"
        echo "****************************************************"
        fi
    done
}

# Run the main script
echo "*********************************************"
echo "        List of S3 Buckets"
echo "*********************************************"
aws s3api list-buckets --query "Buckets[].Name" --output table
#calling main function
main
