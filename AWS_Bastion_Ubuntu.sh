#!/bin/bash
# This Script will creat new machine Then Clone wm-devop Repo on it ,Install Docker-Machine and AWS CommandLine on it.
# please notice that this script also willrestore previously created Key-Pair to it  ,so Make sure you add Bastion'KEYS IN \wm-devop\ssh\bastion


#################################### prerequisite############################################

# To exit the shell when the error occurs
set -e

#Import AWS Environment Global variable like $AWS_DEFAULT_REGION
source ./AWS-ENV-Config.sh
if [ -z $AWS_DEFAULT_REGION ]; then
    echo "Please supply your AWS_DEFAULT_REGION"
    exit 1
fi

# You should create this secuirty Group first before create the machine
echo ------------------- Add Security Group for Bastion
source ./AWS-SG-Add-Bastion.sh

####################################Variable Section Start ################################################
#Machine Variables
MACHINE_NAME="Bastion"
INSTANCE_TYPE=t2.micro

SECURITY_GROUP="Bastion-sg"

SSH_USER=ubuntu
ROOT_SIZE="8"
# Amazon Machine Image for Ubuntu
AMI=ami-060cde69
#This variable depend on $AWS_DEFAULT_REGION value
ZONE="b"

#Key-Pair Variables
#Developer public Key
DEV1_PUBLIC_KEY="id_rsa.pub"

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
    $MACHINE_NAME

eval $(docker-machine env $MACHINE_NAME)

echo Machine IP
docker-machine ip $MACHINE_NAME

#echo  ----------- Create Key-Pair of the remote machine 
#echo  -----------  Should run only one time then to be commented out
#Create Key-Pair of the remote machine ,To Avoid Re-create Key-Pair each time you create the machine after termination , Developer should save the below output on his machine to restore it later   <UserHome>/.ssh/id_rsa.pub
## Should run only one time then to be commented out
#docker-machine ssh $MACHINE_NAME 'ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P ""'
#docker-machine ssh $MACHINE_NAME 'cat ~/.ssh/id_rsa.pub'

#echo  -----------  Restore the existing/old key-pair to the machine
#docker-machine scp ./ssh/$MACHINE_NAME/id_rsa $MACHINE_NAME:~/.ssh/id_rsa
#docker-machine scp ./ssh/$MACHINE_NAME/id_rsa.pub $MACHINE_NAME:~/.ssh/id_rsa.pub

echo  -----------  Restore Developers key-pair to the machine
docker-machine scp ./ssh/$DEV1_PUBLIC_KEY $MACHINE_NAME:~/.ssh/$DEV1_PUBLIC_KEY

function ex() {
    docker-machine ssh $MACHINE_NAME "$@"
}
#To avoid interactive shell with GIT , we add github.com to known_hosts
ex 'ssh-keyscan github.com >> ~/.ssh/known_hosts'

echo  -----------  Add Developers key-pair to authorized_keys------------------
ex 'cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'
ex "cat ~/.ssh/$DEV1_PUBLIC_KEY >> ~/.ssh/authorized_keys"

#It is required that your private key files are NOT accessible by others.
ex 'chmod 0400 ~/.ssh/id_rsa*'

echo  --------------------  Clone wm-devop Repo---------------------------------
#ex 'git clone git@github.com:Mhussein27/wm-devop.git -q'
ex 'git clone https://github.com/Mhussein27/wm-devop.git -q'

echo  ----------- Install Docker machine  -----------------------
ex 'curl -L https://github.com/docker/machine/releases/download/v0.10.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine &&
  chmod +x /tmp/docker-machine &&
  sudo cp /tmp/docker-machine /usr/local/bin/docker-machine'

#AWS CLI Installation can be found here  http://docs.aws.amazon.com/cli/latest/userguide/awscli-install-linux.html

echo  -----------  Install Python as AWS CLI Installation prerequists ---------
ex 'sudo apt-get install python3.4'
echo  ----------- Version of python ------------------------------------
ex 'python3 --version'

echo  -----------  Install pip as AWS CLI Installation prerequists .
echo 'curl -O https://bootstrap.pypa.io/get-pip.py'
ex 'curl -O https://bootstrap.pypa.io/get-pip.py'
echo 'sudo python3 get-pip.py'
ex 'sudo python3 get-pip.py '
echo  ----------- Version of pip----------------
ex 'pip --version'

echo  -----------  use pip to install the AWS CLI.
ex 'sudo pip install awscli --upgrade'
echo  ----------- Version of aws-------------------
ex 'aws --version'

echo  -----------END OF SCRIPT-------------------------------
