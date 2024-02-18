#!/bin/bash

##############################################################
# Author : Ravi
# Date   : 18-02-2024
# DynamoDB.6 DynamoDB tables should have deletion protection enabled
#
##############################################################

echo "*************************************"

region="us-east-1"
# Get the list of table names in the us-east-1 region
tables=$(aws dynamodb list-tables --region us-east-1 --output json --query 'TableNames')

# Check if any table exists
if [ -n "$tables" ]; then
    # Iterate over each table name
    for table in $(echo "${tables}" | jq -r '.[]'); do
        # Check if deletion protection is enabled for the table
        deletion_protection=$(aws dynamodb describe-table --region $region --table-name $table --query 'Table.DeletionProtectionEnabled')
        
        # Check if deletion protection is disabled
        if [ "$deletion_protection" == "false" ]; then
            echo "Deletion protection is disabled for table ==> $table"
            # Perform some operations here if needed
            echo "************************************************"
            echo "Updating the table......"
                aws dynamodb update-table \
                --region us-east-1 \
                --table-name $table \
                --deletion-protection-enabled
            echo "************************************************"
            echo " Enabled for table ==> $table"
            echo "************************************************"
        else
            echo "************************************************"
            echo "Deletion protection is enabled for table ==> $table"
            echo "************************************************"
        fi
    done
else
            echo "************************************************"
            echo "No tables found in the us-east-1 region"
            echo "************************************************"

fi
