
#This Script will creat Jenkins Machine with ubuntu OS for Continouse Integration /Continouse Delivery
#Then it will attach Volume to the machine as backup for jenkins_data

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
source ./AWS-SG-Add-Jenkins.sh

####################################Variable Section Start ################################################
#Machine Variables
MACHINE_NAME="Jenkins"
INSTANCE_TYPE=t2.micro
SECURITY_GROUP="Jenkins-sg"
SSH_USER="ubuntu"
ROOT_SIZE="8"
# Amazon Machine Image for Ubuntu
AMI=ami-060cde69
#This variable depend on $AWS_DEFAULT_REGION value
ZONE="b"

#Jenkins Variable :
JENKINS_FOLDER_HOST="/opt/mount/jenkins_data"
JENKINS_USER_HOST="jenkins"
JENKINS_CONTAINER_NAME="jenkins"
JENKINS_INIT_PW="/var/jenkins_home/secrets/initialAdminPassword"

#Volume Variables :
AWS_ROOT_SIZE=10
#Default Values
AWS_VOLUME_TYPE="gp2"
MOUNT_FOLDER="/opt/mount"
DEVICE_NAME="xvdh"
DEVICE_PATH="/dev/xvdh"

#GIT Variables:
GIT_EMAIL="wasmissing@qarii.com"
GIT_USER="wasmissing"

#Tag Variable
TAG_NAME=Name

#Docker :
DOCKER_COMPOSE_URL='https://github.com/docker/compose/releases/download/1.12.0/docker-compose-Linux-x86_64'


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

###########################
echo  -----------  Restore the existing/old key-pair to the machine
docker-machine scp ./ssh/$MACHINE_NAME/id_rsa $MACHINE_NAME:~/.ssh/id_rsa
docker-machine scp ./ssh/$MACHINE_NAME/id_rsa.pub $MACHINE_NAME:~/.ssh/id_rsa.pub

#####################
##Print INSTANCE_ID
echo --------------------------Running INSTANCE_ID
INSTANCE_ID=$(aws ec2 describe-instances\
    --region $AWS_DEFAULT_REGION\
    --filters "Name=tag:$TAG_NAME,Values=$MACHINE_NAME" "Name=instance-state-name,Values=running"\
    --query 'Reservations[*].Instances[*].[InstanceId]'\
    --output text)
echo "$INSTANCE_ID"

##Print VOLUME_ID
echo ------------------------- VOLUME_ID
VOLUME_ID=$(aws ec2 describe-volumes\
    --region $AWS_DEFAULT_REGION\
    --filters Name=tag-key,Values=$TAG_NAME Name=tag-value,Values="$MACHINE_NAME"\
    --query 'Volumes[*].{ID:VolumeId}'\
    --output text)
echo "$VOLUME_ID"

#########################################Attach existing Volume to the created machine
# you need to make sure that Volume is create if not , please run the below command:
##aws ec2 create-volume --size $VOLUME_SIZE --region $AWS_DEFAULT_REGION --availability-zone $ZONE --output $AWS_DEFAULT_OUTPUT --volume-type $VOLUME_TYPE --tag-specifications 'ResourceType=volume,Tags=[{Key=$TAG_NAME,Value=$MACHINE_NAME}]'

echo "---------------- This example command attaches a volume  to an instance as $DEVICE_PATH"
aws ec2 attach-volume\
    --volume-id "$VOLUME_ID"\
    --instance-id "$INSTANCE_ID"\
    --device $DEVICE_NAME\
    --region $AWS_DEFAULT_REGION\
    --output $AWS_DEFAULT_OUTPUT

echo ----------------- Making an Amazon EBS Volume Available for Use

######################
eval $(docker-machine env $MACHINE_NAME)

echo "----------------------- $MACHINE_NAME Machine IP"
docker-machine ip $MACHINE_NAME
JenkinsIP=$(docker-machine ip $MACHINE_NAME)

####################
function ex() {
    docker-machine ssh $MACHINE_NAME "$@"
}
ex "sudo mkdir -p $MOUNT_FOLDER"
echo "sudo mount $DEVICE_PATH $MOUNT_FOLDER"
ex "sudo mount $DEVICE_PATH $MOUNT_FOLDER"
ex "lsblk"
echo "Run df -h to see The available Mounting Points"
ex "df -h"
echo "Create user $JENKINS_USER_HOST "
ex "sudo useradd $JENKINS_USER_HOST"
ex "sudo usermod -aG docker jenkins"
ex "sudo chown $JENKINS_USER_HOST -R $MOUNT_FOLDER/"
# to avoid touch: cannot touch ‘/var/jenkins_home/copy_reference_file.log’: Permission denied
ex "sudo chmod 777 -R $MOUNT_FOLDER/"
echo ---------------- service docker restart
ex "sudo service docker restart"

echo ---------------- Install Docker Compose
#Install Using Curl
ex "sudo chmod 777 /usr/local/bin/"
ex " curl -L $DOCKER_COMPOSE_URL > /usr/local/bin/docker-compose"

########################## Run Jenkins Container ##############################

echo "--------------Pull Jenkins Image "
# on Jenkins host
ex "sudo mkdir -p $JENKINS_FOLDER_HOST"
#ex "sudo useradd $JENKINS_USER_HOST"
#ex "sudo usermod -aG docker jenkins"
ex "sudo chown $JENKINS_USER_HOST -R $JENKINS_FOLDER_HOST/"
# to avoid touch: cannot touch ‘/var/jenkins_home/copy_reference_file.log’: Permission denied
ex "sudo chmod 777 -R $JENKINS_FOLDER_HOST/"

ex "sudo chmod 777 /var/run/docker.sock"
###Docker Compose
ex "sudo chown $JENKINS_USER_HOST -R /usr/local/bin/docker-compose"
ex "sudo chmod 777 /usr/local/bin/docker-compose"

ex 'sudo docker pull jenkins'
#port 50000 for jenkins slave
#$(which docker)
echo "-------------- Run  Jenkins Container "
ex "sudo docker run -d\
 -p 8080:8080 \
 -p 50000:50000 \
 --name $JENKINS_CONTAINER_NAME \
 -v $JENKINS_FOLDER_HOST/:/var/jenkins_home \
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v /usr/bin/docker/:/usr/bin/docker \
 -v /usr/local/bin/docker-compose:/usr/local/bin/docker-compose \
 jenkins"
##############################
 echo  -------------- Restore the existing/old key-pair to Jenkins Container
docker-machine scp ./ssh/$MACHINE_NAME/id_rsa $MACHINE_NAME:$JENKINS_FOLDER_HOST/.ssh/id_rsa
docker-machine scp ./ssh/$MACHINE_NAME/id_rsa.pub $MACHINE_NAME:$JENKINS_FOLDER_HOST/.ssh/id_rsa.pub

echo "ssh-keyscan -H github.com >> $JENKINS_FOLDER_HOST/.ssh/known_hosts"
# To Avoid Key Verification Failed
ex "ssh-keyscan -H github.com >> $JENKINS_FOLDER_HOST/.ssh/known_hosts"
# To Avoid #It is required that your private key files are NOT accessible by others.
#0400
ex "sudo chmod 777 $JENKINS_FOLDER_HOST/.ssh/id_rsa*"

######################
echo  -----------Configure Git user
ex "git config --global user.email $GIT_EMAIL"
ex "git config --global user.name $GIT_USER"
######################

echo "---------- Jenkins admin Intial Password location-------"
#docker-machine ssh Jenkins "sudo docker exec jenkins 'cat /var/jenkins_home/secrets/initialAdminPassword'"

echo ------------------- List Container
ex "sudo docker ps -a"
echo "jenkins URL : $JenkinsIP:8080 "

