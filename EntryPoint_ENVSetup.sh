#!/bin/bash
# Any subsequent(*) commands which fail will cause the shell script to exit
# immediately

# set -e

# ------------------- prepare Bastion Machine
echo ------------------- Export AWS-ENV-Configure
bash -e ./AWS-ENV-Config.sh

echo ------------------- Terminate Bastion machine if exists
bash -e ./AWS-Machine-Terminate.sh Bastion
echo -------------------- Wait till the machine terminated
sleep 1m
echo ------------------- Delete Security Group for Bastion if exists
bash  ./AWS-SG-delete.sh Bastion-sg

echo ------------------- Create Ubuntu machine Bastion with the needed security group 
bash -e ./AWS_Bastion_Ubuntu.sh
eval $(docker-machine env Bastion)
docker-machine ssh Bastion bash ./wm-devop/ENVSetup.sh
