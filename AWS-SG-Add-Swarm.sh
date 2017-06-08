#This Script will create an AWS VPC Security Group with rules to allow access to each IP at the port specified 

# To exit the shell when the error occurs
set -e

#Import AWS Environment Global variable like $AWS_DEFAULT_REGION
source ./AWS-ENV-Config.sh
if [ -z $AWS_DEFAULT_REGION ]; then
    echo "Please supply your AWS_DEFAULT_REGION"
    exit 1
fi
####################################Variable Section Start ################################################
GROUP_NAME="swarm-sg"
GROUP_DESCRIPTION="This is Jenkins Security group"


####################################Variable Section End ################################################


echo '-------------------create-security-group for jenkins Machine '
aws ec2 create-security-group --group-name "$GROUP_NAME" --description "$GROUP_DESCRIPTION" --vpc-id $VPC_ID --query 'GroupId' --output text
#dispaly Security group
aws ec2 describe-security-groups --group-names $GROUP_NAME --output json

#The following command Add Inbound rule to the created security group:
# Any Where : 0.0.0.0/0
####

echo '------------------Add Inbound rule to the created security group swarm  Machine '
# Swarm Communication
aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol tcp --port 22 --cidr 0.0.0.0/0 --output json
aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol tcp --port 2377 --cidr 0.0.0.0/0 --output json
# to avoid There was an error validating certificates for host "0.0.0.0:2376
aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol tcp --port 2376 --cidr 0.0.0.0/0 --output json
aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol tcp --port 7946 --cidr 0.0.0.0/0 --output json
aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol udp --port 7946 --cidr 0.0.0.0/0 --output json
aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol udp --port 4789 --cidr 0.0.0.0/0 --output json

aws ec2 describe-security-groups --group-names $GROUP_NAME --output json