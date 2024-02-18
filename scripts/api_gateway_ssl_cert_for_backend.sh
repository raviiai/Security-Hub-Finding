#!/bin/bash

##############################################################
# Author : Ravi
# Date   : 18-02-2024
# APIGateway.2 API Gateway REST API stages should be configured to use SSL certificates for backend authenticatin
#
##############################################################
region="us-east-1"
stage="Development"
description="SSL Certificate for HTTP requests authentication."

echo "*****************************************"
aws apigateway get-rest-apis \
    --region "$region" \
    --output table \
    --query 'items[*].id'
echo "*****************************************"

rest_apis=$(aws apigateway get-rest-apis --region "$region" --output text --query 'items[*].id')
for api in $rest_apis; do

    echo "********************************"
    echo "Listing Stages for API: $api"
    echo "********************************"
    aws apigateway get-stages \
        --region "$region" \
        --rest-api-id "$api" \
        --output table

    # Retrieve client certificate ID for the specified stage
    client_certificate_id=$(aws apigateway get-stages \
        --region "$region" \
        --rest-api-id "$api" \
        --query "item[?stageName=='$stage'].clientCertificateId" \
        --output text)

    # Check if client_certificate_id is empty
    if [ -z "$client_certificate_id" ]; then
        # Generate a new client certificate
        generated_certificate=$(aws apigateway generate-client-certificate \
            --region "$region" \
            --description "$description")

        # Extract the certificate ID from the generated certificate response
        certificate_id=$(echo "$generated_certificate" | jq -r '.clientCertificateId')

        # Update stage configuration with the new client certificate
        aws apigateway update-stage \
            --region "$region" \
            --rest-api-id "$api" \
            --stage-name "$stage" \
            --patch-operations op=replace,path=/clientCertificateId,value="$certificate_id"

        echo "New client certificate generated and associated with the stage."
    else
        echo "Client certificate already exists for the specified stage."
    fi

done
