#!/bin/bash

###############################################
# Author: Ravi
# Date  : 19-02-2024
# this script will encrypt the root volume of instance
#
###############################################
instance_id=$1 
region="us-east-1"
######### Part 1 section - starts here ##############
# Stop instances
echo "Stop instance"
aws ec2 stop-instances --instance-ids $instance_id

while [ "$instance_state" != "stopped" ]
do
instance_state=`aws ec2 describe-instances --instance-ids $instance_id | grep -A 3 "State" | grep -i "Name" | awk -F'\"' '{ print  $4 }'`
echo "Waiting to instance state changed to STOPPED"
done

echo "Get Volume ID not encrypted"
volume=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[].Instances[].BlockDeviceMappings[].Ebs.VolumeId' --output text)

echo $volume

echo "Create snapshot of Volume"
snapshot_id=`aws ec2 create-snapshot --volume-id "$volume" | grep -i "SnapshotId" | awk -F'\"' '{ print $4 }'`
echo $snapshot_id

while [ "$snapshot1_status" != "completed" ]
do
snapshot1_status=`aws ec2 describe-snapshots --snapshot-ids $snapshot_id | grep -i "State" | awk -F'\"' '{ print  $4 }'`
echo "Waiting for Source snapshot creation to be completed"
done

echo "Copy the snapshot and encrypt it"
copied_snapshot=`aws --region $region ec2 copy-snapshot --source-region $region --source-snapshot-id $snapshot_id --encrypted  | grep -i "SnapshotId" | awk -F'\"' '{ print  $4 }'`
echo $copied_snapshot

while [ "$snapshot2_status" != "completed" ]
do
snapshot2_status=`aws ec2 describe-snapshots --snapshot-ids $copied_snapshot | grep -i "State" | awk -F'\"' '{ print  $4 }'`
echo "Waiting form copied snapshot creation to be completed"
done
######### Part 1 section - ends here ##############

######### Part 2 section - starts here ##############
echo "Create new volume from encrypted snapshot"
new_encrypt_volume=`aws ec2 create-volume --size 10 --region $region --availability-zone us-east-1b --volume-type gp2 --snapshot-id $copied_snapshot | grep -i "VolumeID" | awk -F'\"' '{ print  $4 }'`
echo $new_encrypt_volume

while [ "$new_volume_state" != "available" ]
do
new_volume_state=`aws ec2 describe-volumes --volume-ids $new_encrypt_volume | grep -i "State" | awk -F'\"' '{ print  $4 }'`
echo "Waiting for new volume creation to be completed"
done

echo "Detach un-encrypted volume"
aws ec2 detach-volume --volume-id $volume

while [ "$old_volume_state" != "available" ]
do
old_volume_state=`aws ec2 describe-volumes --volume-ids $volume | grep -i "State" | awk -F'\"' '{ print  $4 }'`
echo "Waiting for new volume creation to be completed"
done

echo "Attach newly encrypted volume"
aws ec2 attach-volume --volume-id $new_encrypt_volume --instance-id $instance_id --device /dev/sda1

while [ "$new_volume_state" != "in-use" ]
do
old_volume_state=`aws ec2 describe-volumes --volume-ids $new_encrypt_volume | grep -i "State" | awk -F'\"' '{ print  $4 }'`
echo "Waiting for attaching new volume to be completed"
done

echo " Start instances"
aws ec2 start-instances --instance-ids $instance_id
######### Part 2 section - ends here ##############