# Creates an EBS volume that can be attached to an instance in the same Availability Zone and Making an Amazon EBS Volume Available for Use.
# To exit the shell when the error occurs
set -e

#Import AWS Environment Global variable like $AWS_DEFAULT_REGION
source ./AWS-ENV-Config.sh
if [ -z $AWS_DEFAULT_REGION ]; then
    echo "Please supply your AWS_DEFAULT_REGION"
    exit 1
fi
####################################Variable Section Start ################################################
VOLUME_SIZE=12

#http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html
#General purpose SSD volume that balances price and performance for a wide variety of transactional workloads
VOLUME_TYPE=gp2

ZONE='eu-central-1b'
MACHINE_NAME="Jenkins"

#Tag Variable
TAG_NAME="Name"

JENKINS_USER_HOST=jenkins
MOUNT_FOLDER=/opt/mount
CONTAINER_NAME=jenkins


# The below values are dummy 
VOLUME_ID='vol-0aa57b6ee7b95b'
INSTANCE_ID='i-0bd77571386a9e'

####################################Variable Section End ################################################

## To create a new volume from a snapshot Add (--snapshot-id)
aws ec2 create-volume --size $VOLUME_SIZE --region $AWS_DEFAULT_REGION --availability-zone $ZONE --output $AWS_DEFAULT_OUTPUT --volume-type $VOLUME_TYPE --tag-specifications "ResourceType=volume,Tags=[{Key=$TAG_NAME,Value=$MACHINE_NAME}]"


##echo---------Describe Volume 
echo  ------------------Describe Volume and filter only VolumeId
aws ec2 describe-volumes --region $AWS_DEFAULT_REGION --filters Name=tag-key,Values="$TAG_NAME" Name=tag-value,Values="$MACHINE_NAME" --query 'Volumes[*].{ID:VolumeId,Tag:Tags}'
aws ec2 describe-volumes --region $AWS_DEFAULT_REGION --filters Name=tag-key,Values="$TAG_NAME" Name=tag-value,Values="$MACHINE_NAME" --query 'Volumes[*].{ID:VolumeId}' --output text


#echo "-----------------This example command attaches a volume  to an instance as /dev/xvdh"
#aws ec2 attach-volume --volume-id $VOLUME_ID --instance-id $INSTANCE_ID --device xvdh --region $AWS_DEFAULT_REGION --output $AWS_DEFAULT_OUTPUT
##aws ec2 attach-volume --volume-id vol-0aa57b6ee7b95bc92 --instance-id i-0bd77571386a9eddf --device xvdh --region eu-central-1 --output text

#echo ------------------Making an Amazon EBS Volume Available for Use

#function ex() {
#    docker-machine ssh $MACHINE_NAME "$@"
#}
#ex "sudo mkdir -p $MOUNT_FOLDER"
#ex "sudo mount /dev/xvdh $MOUNT_FOLDER"
#ex "sudo chown $JENKINS_USER_HOST -R $MOUNT_FOLDER/"
# to avoid touch: cannot touch ‘/var/jenkins_home/copy_reference_file.log’: Permission denied
#ex "sudo chmod 777 -R $MOUNT_FOLDER/" 
#echo -----------------service docker restart
#ex "sudo service docker restart"
#echo ------------------- List Container
#ex "sudo docker ps -a"
#echo --------------------Restart Container
#ex "sudo docker start $CONTAINER_NAME"


#aws ec2 detach-volume --volume-id vol-098a1d3e837cfef24 --region $AWS_DEFAULT_REGION --output $AWS_DEFAULT_OUTPUT