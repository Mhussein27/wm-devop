#This script will create Docker Swarm Cluster:(Node-1"Leader",Node-2"Worker",Node-3"Worker") : Machines with Rancher OS to act as Cluster .

#################################### prerequisite############################################

# To exit the shell when the error occurs
set -e

#Import AWS Environment Global variable like $AWS_DEFAULT_REGION
source ./AWS-ENV-Config.sh
if [ -z $AWS_DEFAULT_REGION ]; then
    echo "Please supply your AWS_DEFAULT_REGION"
    exit 1
fi

#You should create this secuirty Group first before create the machine
source ./AWS-SG-Add-Swarm.sh

####################################Variable Section Start ################################################
#Machine Variables
INSTANCE_TYPE=t2.micro
SECURITY_GROUP="swarm-sg"
SSH_USER="rancher"
ROOT_SIZE="8"
# Amazon Machine Image for Rancher
AMI=ami-27ac7e48
#This variable depend on $AWS_DEFAULT_REGION value
ZONE="b"

#Volume Variables : 
AWS_ROOT_SIZE=10
#Default Values
AWS_VOLUME_TYPE="gp2"

#Tag Variable
TAG_NAME=Name
TAG_VALUE="Swarm"

####################################Variable Section End ################################################


echo  ----------- Run docker-machine Command to Create Machine
for i in 1 2 3 ; do
docker-machine create\
    --driver amazonec2\
    --amazonec2-zone $ZONE\
    --amazonec2-ami $AMI\
    --amazonec2-root-size $ROOT_SIZE\
    --amazonec2-ssh-user $SSH_USER\
    --amazonec2-instance-type $INSTANCE_TYPE\
	--amazonec2-region $AWS_DEFAULT_REGION\
	--amazonec2-security-group $SECURITY_GROUP \
    --amazonec2-volume-type $AWS_VOLUME_TYPE \
    --amazonec2-root-size $AWS_ROOT_SIZE \
	--amazonec2-tags $TAG_NAME,$TAG_VALUE-node-$i \
	--amazonec2-ssh-user $SSH_USER \
    node-$i
done

eval $(docker-machine env node-1)

docker swarm init --advertise-addr $(docker-machine ip node-1)
# --listen-addr $(docker-machine ip node-1):2377

TOKEN=$(docker swarm join-token -q worker)

for i in 2 3; do
    eval $(docker-machine env node-$i)

    docker swarm join --token $TOKEN $(docker-machine ip node-1):2377
done

eval $(docker-machine env node-1)
docker info
docker node ls
echo "---------- The Swarm Cluster is set up!"





