# This Script to creat Local Docker Registry , to push and Pull Images  
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
source ./AWS-SG-Add-Registry.sh

####################################Variable Section Start ################################################
#Machine Variables 
MACHINE_NAME="Registry"
INSTANCE_TYPE=t2.micro
SECURITY_GROUP="Registry-sg"	
SSH_USER="ubuntu"
ROOT_SIZE="8"
# Amazon Machine Image for Ubuntu
AMI=ami-060cde69
#This variable depend on $AWS_DEFAULT_REGION value
ZONE="b"

#Registry Variable :
Registry_FOLDER_HOST="/opt/mount/Registry_data"
Registry_Container_Name="Registry"

#Volume Variables : 
AWS_ROOT_SIZE=10
#Default Values
AWS_VOLUME_TYPE="gp2"


#Tag Variable
TAG_NAME=Name

####################################Variable Section End ################################################

	
echo  ----------- Run docker-machine Command to Create Machine
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
	--amazonec2-tags $TAG_NAME,$MACHINE_NAME \
	--amazonec2-ssh-user $SSH_USER \
    $MACHINE_NAME
   

eval $(docker-machine env $MACHINE_NAME)

echo "------------------------$MACHINE_NAME Machine IP"
docker-machine ip $MACHINE_NAME
RegistryIP=$(docker-machine ip $MACHINE_NAME)

##Print Instance ID
echo --------------------------Instance ID 
aws ec2 describe-instances --region $AWS_DEFAULT_REGION --filters "Name=tag:$TAG_NAME,Values=$MACHINE_NAME" --query 'Reservations[*].Instances[*].[InstanceId]' --output text

##Print Public DNS
echo --------------------------Instance ID 
aws ec2 describe-instances --region $AWS_DEFAULT_REGION --filters "Name=tag:$TAG_NAME,Values=$MACHINE_NAME" --query 'Reservations[*].Instances[*].PublicDnsName' --output text

function ex() {
    docker-machine ssh $MACHINE_NAME "$@"
}

ex "sudo mkdir -p $Registry_FOLDER_HOST"
echo 'sudo docker pull registry'
ex 'sudo docker pull registry'

echo "Running a Registry Container on with External Storage (a host-mounted Docker volume)"
ex "sudo docker run -d -p 5000:5000 --name $Registry_Container_Name --restart always   -v $Registry_FOLDER_HOST:/var/lib/registry  registry"
ex 'ls -la $Registry_FOLDER_HOST'


#For Testing Purpose
echo 'Pull & Push hello-world Registry 127.0.0.1:5000'
ex 'sudo docker pull hello-world'
ex 'sudo docker tag hello-world 127.0.0.1:5000/hello-world'
ex 'sudo docker push 127.0.0.1:5000/hello-world'
ex 'sudo docker pull 127.0.0.1:5000/hello-world'

echo "ls -la $Registry_FOLDER_HOST/docker/registry/v2/repositories" 
ex "ls -la $Registry_FOLDER_HOST/docker/registry/v2/repositories"
