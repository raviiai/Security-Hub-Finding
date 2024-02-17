#!/bin/bash

##############################################################
# Author : Ravi
# Date   : 17-02-2024
# Logging of delivery status should be enabled for notification messages sent to a topic
#
##############################################################
# Set your AWS region
AWS_REGION="us-east-1"

set -e

echo "******************************************"
echo "Listing all SNS topics..."
aws sns list-topics --region $AWS_REGION --output table --query 'Topics[*].TopicArn'
echo "******************************************"

topics=$(aws sns list-topics --region $AWS_REGION --output text --query 'Topics[*].TopicArn')

# Get your AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

for topic in $topics; do
    echo "********************************************"
    echo "Enabling Notification message sent to topic: $topic"
    echo "********************************************"

    aws sns set-topic-attributes --region $AWS_REGION --topic-arn $topic --attribute-name Policy --attribute-value \
            "{
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "logs:CreateLogGroup",
                        "logs:CreateLogStream",
                        "logs:PutLogEvents",
                        "logs:PutMetricFilter",
                        "logs:PutRetentionPolicy"
                    ],
                    "Resource": [
                        "*"
                    ]
                }
            ]
        }"

    echo "Delivery status logging enabled for SNS topic: $topic"
done
