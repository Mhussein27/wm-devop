# Project Title: WM-DevOps

The aim of the project is to Automate Machine/Environment Creation On Amazon Web Service , so you can make your Environment up or down in short time and with a few scripts.

## Introduction 
We need to create the below machine , so we can build and deploy any App using a CI pipeline consisting of Docker, GitHub, Jenkins, and Docker Registry.

- Bastion : Machine with ubuntu OS which hosts wm-devop folder with all DevOps Scripts.
		   To make the Environment up ,all the Script should be run from there .

- Jenkins : Machine with ubuntu OS for Continouse Integration /Continouse Delivery.

- Registry: Machine with ubuntu OS to act as Docker Local Registry .

- Swarm:(Node-1"Leader",Node-2"Worker",Node-3"Worker") : Machines with Rancher OS to act as Swarm Cluster .



### Prerequisites

What things you need to install the software and how to install them

1- Install the below tools locally on your Machine

```
       - "Docker Machine" you can follow the Installation Steps mentioned in the below link 
	   https://docs.docker.com/machine/install-machine/#installing-machine-directly  
```

```
       - "AWS Command Line" you can follow the Installation steps mentioned in the below link 
	   http://docs.aws.amazon.com/cli/latest/userguide/installing.html	  
```
```
	   - "Git Bash" if your OS is Windows as you will use GIT Bash to run any script from it 
       https://git-scm.com/downloads
```

### How to run Scripts and Setup the Environment

A step by step that tell you How to get your env running

1- Generate the ssh key for your machine ,then Copy id_rsa.pub in "wm-devop\ssh" folder 

```
	Run This Command (ssh-keygen) on your commandline ,the output will be generated by default in <UserHome>/.ssh/id_rsa.pub
```
2- Edit "AWS-ENV-Config.sh" with your AWS Account details (ex: AWS_ACCESS_KEY and AWS_SECRET_ACCESS_KEY)
 	
3-This Step will be done only One Time : to Create Backup Volume for Jenkins machine.
	  
```
	Run "AWS-Volume.Sh" script
```
4-Then Run This Script `EntryPoint_ENVSetup.sh`on your commandline , use Git Bash if you are in Windows

5-Open your AWS Consule , Then you should see the above Machines up and running inyour EC2 Frankfurt region .

## Scripts Description

* **AWS-ENV-Config.sh** - *This Scrpt will Export AWS Access & secret key and Region*

* **EntryPoint_ENVSetup.sh** - *This Script will prepare the entry point to setup the Environment by doing the below:*

	- Delete Bastion Machine on AWS using this Script AWS-Machine-Terminate.sh
	- Delet existing Bastion Security Groupon AWS using this script AWS-SG-Delete.sh
	- Add Bastion Security Group on AWS using this script AWS-SG-Add-Bastion.sh
	- Create Bastion Machine on AWS + Docker machine +AWS Command line on it using this script AWS_Bastion_Ubuntu.sh
	- Run ENVSetup.sh script on Bastion Machine
	
* **ENVSetup.sh** - *This Script will Setup the Environment and Create Swarm ,Registry,Jenkins Machines*

	- Create Swarm Security Group using this script AWS-SG-Add-Swarm.sh
	- Create Swarm Machines on AWS using this Script AWS-swarm-cluster-RancherOS.sh
	- Create Registry Security Group using this Script AWS-SG-Add-Registry.sh
	- Create Registry Machine on AWS using this Script DockerRegistry.sh
	- Create jenkins Security Group using this Script AWS-SG-Add-Jenkins.sh
	- Create jenkins Machines on AWS using this Script Jenkins.sh
	
* **ENVShutdown.sh** - *This Script will Delete all the machine and it's security Group, except Bastion..please notice You need to run this Script from Bastion*

* **AWS-Machine-Terminate.sh** - *This Script will Terminate any machine but it takes machine name as input in Shell*

* **AWS-SG-Delete.sh** - *This Script will Delete any Security Group but it takes Security Group name as input in Shell*

* **AWS-Volume.Sh** - *This Script will Create an EBS volume that can be attached to an instance in the same Availability Zone and Making an Amazon EBS Volume Available for Use.
                  you need this Volume as Backup point not to lose your data after you terminate the machine*

###Notes :

1-You can Create SSH Key-Pair of your machine and the remote machines like Jenkis and Bastion and save them In wm-devop\ssh
To Avoid Re-create Key-Pair each time you Re-create the machine after it's termination.

2-You don't need to create Bastion machine , for example : You Can create run This script "DockerRegistry.sh" directly to create only Docker Registry machine.

3- If you need to Setup Jenkins Machine Only <YOU NEED TO RUN THIS SCRIPT "AWS-Volume.Sh" Only one time> then you can run Jenkins.sh directly any time after that without any prerequists.

  

## Contributing
When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.

## Future Work
We need to use Ansible to do the same task.

## Versioning

We can use [SemVer](http://semver.org/) for versioning. 

## Authors

* **Maha Hussein Sallam** - (https://github.com/Mhussein27)

list of [contributors]who participated in this project:

* **Diaa Kasem** -(https://github.com/diaakasem/) 

## License

## Acknowledgments
