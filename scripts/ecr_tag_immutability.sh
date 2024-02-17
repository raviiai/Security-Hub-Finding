#!/bin/bash

##############################################################
# Author : Ravi
# Date   : 17-02-2024
# ECR.2 ECR private repositories should have tag immutability configured
#
##############################################################

AWS_REGION="us-east-1"
set -e

# Get a list of all ECR repositories
aws ecr describe-repositories --region $AWS_REGION --query 'repositories[*].repositoryName' --output table
repositories=$(aws ecr describe-repositories --region $AWS_REGION --query 'repositories[*].repositoryName' --output text)
# Loop through each repository and set tag immutability
for repository in $repositories; do
    echo "************************************************"
    echo "Setting tag immutability for repository: $repository"
    aws ecr put-image-tag-mutability --repository-name $repository --image-tag-mutability IMMUTABLE --region $AWS_REGION
    echo "----------------------------------------------"
    echo "Successful"
    echo "************************************************"
done