#!/bin/bash
# This Script will create an AWS VPC Security Group with rules to allow access
# to each IP at the port specified

# To exit the shell when the error occurs
set -e

#Import AWS Environment Global variable like $AWS_DEFAULT_REGION
source ./AWS-ENV-Config.sh
if [ -z $AWS_DEFAULT_REGION ]; then
    echo "Please supply your AWS_DEFAULT_REGION"
    exit 1
fi

#################### Variable Section Start ###################################

GROUP_NAME="Bastion-sg"
GROUP_DESCRIPTION="This is Bastion Security group"

######################## Variable Section End #################################

echo '------------------ Create-security-group for Machine and print the GroupId on the shell '
aws ec2 create-security-group\
    --group-name "$GROUP_NAME"\
    --description "$GROUP_DESCRIPTION"\
    --vpc-id $VPC_ID\
    --query 'GroupId'\
    --output text

#dispaly Security group
aws ec2 describe-security-groups\
    --group-names $GROUP_NAME\
    --output json

#The following command Add Inbound rule to the created security group:
# Any Where : 0.0.0.0/0

echo '----------------- Add Inbound rule to the created security group '
aws ec2 authorize-security-group-ingress \
    --group-name $GROUP_NAME \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 \
    --output json

# Docker Machine
aws ec2 authorize-security-group-ingress \
    --group-name $GROUP_NAME \
    --protocol tcp \
    --port 2376 \
    --cidr 0.0.0.0/0 \
    --output json

aws ec2 authorize-security-group-ingress \
    --group-name $GROUP_NAME \
    --protocol tcp \
    --port 2377 \
    --cidr 0.0.0.0/0 \
    --output json

# This Command To dispaly Security group after adding Inbound Rule
aws ec2 describe-security-groups \
    --group-names $GROUP_NAME \
    --output json

