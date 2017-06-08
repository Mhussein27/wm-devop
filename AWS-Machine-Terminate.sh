set -e
source ./AWS-ENV-Config.sh
if [ -z $AWS_DEFAULT_REGION ]; then
    echo "Please supply your AWS_DEFAULT_REGION"
    exit 1
fi

echo please write in your shell "./AWS-Machine-Terminate.sh <Machine name>"
echo ------------------------ docker-machine rm -f $1
docker-machine rm -f $1


echo "If Machine terminated successfully  ,wait 2 minutes then run AWS-SG-Delete.sh to delete security group after machine termination" 
