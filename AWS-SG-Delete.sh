set -e
source ./AWS-ENV-Config.sh
if [ -z $AWS_DEFAULT_REGION ]; then
    echo "Please supply your AWS_DEFAULT_REGION"
    exit 1
fi


echo please write in your shell "./AWS-SG-Delete.sh <Security Group name>"

#aws ec2 describe-security-groups --group-names bastion-sg --output json

echo -------------------Delete-security-group for $1 
aws ec2 delete-security-group --group-name $1 --output json