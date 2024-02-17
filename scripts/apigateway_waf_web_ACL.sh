#!/bin/bash

##############################################################
# Author : Ravi
# Date   : 17-02-2024
# APIGateway.4 API Gateway should be associated with a WAF Web ACL
#
##############################################################
region="ap-south-1"
web_acl_id="c58a3e99-7bf9-4e78-aec0-aebc23cd5e10"
stage="Development"
echo "*****************************************"
aws apigateway get-rest-apis \
    --region $region \
    --output table \
    --query 'items[*].id'
echo "*****************************************"

rest_apis=$(aws apigateway get-rest-apis --region $region --output text --query 'items[*].id')
for api in $rest_apis;do

    echo "********************************"
    echo "Listing Stages for API: $api"
    echo "********************************"
    aws apigateway get-stages \
        --region $region \
        --rest-api-id $api \
        --output table
    echo "********************************"
    echo " Running Get Stages webAclArn"
    echo "********************************"

    aws waf-regional associate-web-acl \
        --region $region \
        --web-acl-id $web_acl_id \
        --resource-arn "arn:aws:apigateway:$region::/restapis/$api/stages/$stage"
done






# if there is Stages
# echo "********************************"
# echo " Running Get Stages"
# echo "********************************"
# aws apigateway get-stages \
#     --region $region \
#     --rest-api-id $api \
#     --output table \
#     --query 'item[*].stageName'