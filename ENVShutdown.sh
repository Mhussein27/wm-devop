#!/bin/bash

echo --------------------Running ENVShutdown.sh from Bastion Machine
echo --------------------Export AWS-ENV-Configure
bash -e ./AWS-ENV-Config.sh
##########
echo --------------------Terminate Swarm Machines
for i in 1 2 3; do
bash -e ./AWS-Machine-Terminate.sh node-$i
done
####
echo --------------------Terminate Registry machine
bash -e ./AWS-Machine-Terminate.sh Registry
###
echo --------------------Terminate Jenkins machine
bash -e ./AWS-Machine-Terminate.sh Jenkins
####
echo ---------------------Wait till the machine terminated
sleep 3m
#########
echo --------------------Delete Security Group for registry
bash  ./AWS-SG-Delete.sh registry-sg
##########
echo --------------------Delete Security Group for Jenkins
bash  ./AWS-SG-Delete.sh jenkins-sg
#########
echo --------------------Delete Security Group for swarm
bash  ./AWS-SG-Delete.sh swarm-sg
