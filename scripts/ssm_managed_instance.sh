#!/bin/bash

region="us-east-1"
# Fetch running instance IDs
aws ec2 describe-instances --region $region --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].InstanceId' --output table
instance_ids=$(aws ec2 describe-instances --region $region --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].InstanceId' --output text)

# Iterate over each instance
for instance_id in $instance_ids; do
    echo "Configuring instance: $instance_id"
    
    # Create IAM role
    aws iam create-role --role-name ssm-role-for-managed-instances --assume-role-policy-document file://iam_trust_policy.json
    
    #Attach IAM policy
    aws iam attach-role-policy --role-name ssm-role-for-managed-instances --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
        echo "****************************************************************"
        echo " Creating Instance Profile"
        echo "****************************************************************"
    # Create instance profile
    aws iam create-instance-profile --instance-profile-name ssm-core-instance-profile
        echo "****************************************************************"
        echo " Adding role to instance profile"
        echo "****************************************************************"
    # Add role to instance profile
    aws iam add-role-to-instance-profile --role-name ssm-role-for-managed-instances --instance-profile-name ssm-core-instance-profile
        echo "****************************************************************"
        echo " Associating IAM instance Profile"
        echo "****************************************************************"
    # Associate IAM instance profile
    aws ec2 associate-iam-instance-profile --iam-instance-profile Name=ssm-core-instance-profile --instance-id $instance_id
    # Create SSM associations
        echo "****************************************************************"
        echo " Creating SSM associations"
        echo "****************************************************************"
        echo "****************************************************************"
    aws ssm create-association --name "AWS-UpdateSSMAgent" --targets "Key=instanceids,Values=$instance_id" --schedule-expression "cron(0 5 ? * SUN *)" --output text
        echo "****************************************************************"
    aws ssm create-association --name "AWS-GatherSoftwareInventory" --targets "Key=instanceids,Values=$instance_id" --schedule-expression "rate(1 day)" --parameters "applications=Enabled,awsComponents=Enabled,customInventory=Enabled,instanceDetailedInformation=Enabled,networkConfig=Enabled,services=Enabled,windowsRoles=Enabled,windowsUpdates=Enabled" --output text
        echo "****************************************************************"
    aws ssm create-association --name "AWS-RunPatchBaseline" --targets "Key=instanceids,Values=$instance_id" --parameters "Operation=Scan,RebootOption=NoReboot" --output text
        echo "****************************************************************"
    
        echo "Configuration complete for instance: $instance_id"
done

    echo "All instances configured successfully"
    echo "****************************************************************"
