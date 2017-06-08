echo --------------------Running ENVSetup.sh from Bastion Machine 
cd wm-devop/
echo --------------------Export AWS-ENV-Configure
bash -e ./AWS-ENV-Config.sh
echo --------------------Run ENVShutDown to terminate the machines if exist before creating them again 
bash -e ./ENVShutdown.sh
#################
echo --------------------Create Rancher machine for SWARM with the needed security group 
bash -e ./AWS-swarm-cluster-RancherOS.sh
#########
echo --------------------Create ubuntu machine for Registry with the needed security group 
bash -e ./DockerRegistry.sh
##########
echo --------------------Create ubuntu machine for Jenkins with the needed security group 
bash -e ./Jenkins.sh
#########