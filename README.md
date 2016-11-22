# k8sdeployer [![Build Status](https://travis-ci.org/tsvenkat/k8sdeployer.svg?branch=master)](https://travis-ci.org/tsvenkat/k8sdeployer)
Setup k8s on existing Ubuntu 16.04 boxes using kubeadm, docker and ansible

# Introduction
The main intent of this project is to setup a docker based development environment
for Kubernetes with existing Ubuntu 16.04 installations.
It uses the newer kubeadm based deployment. Assuming the following workflow for
a k8s developer:

# To auto spin up VMs and deploy k8s in it

1. git clone https://github.com/tsvenkat/k8sdeployer
2. ./deploy_k8s.sh
   This should build the image localhost/k8sdeployer which does all the hard
   work of setting up an environment to deploy kubernetes on the specified
   Ubuntu 16.X nodes. It also spins up VMs using Vagrant/Virtualbox, 
   sets up the RSA keys and deploys k8s in it 

# To make it work with existing Ubuntu installations

1. Edit the inventory.yml file and update the fields
2. Copy the id_rsa and id_rsa.pub files needed to communicate with the Ubuntu
   boxes under the ssh_config folder
3. Edit the deploy_k8s.sh script and comment the line that does the vagrant up
   This will be made automatic in the script, but manual for now
4. Run the deploy_k8s.sh script to bring up a container with name "deployer" that
   runs a script to setup the k8s deployment and tail the logs. Once this is done,
   it shows the Kubernetes cluster details and the developer could then:

    *docker exec -it deployer /bin/bash*
   to shell into the container and start using it. As a convenience, the deployer
   is configured with kubectl and helm tools 

# Requirements
* Git
* Docker (tested with v1.12.3)
* Linux shell
(additional requirements if you want the VMs to be created locally)
* Virtualbox (5.1.8 or later)
* Vagrant (1.8.7 or later)

# Tip: creating RSA key/pair
ssh-keygen -t rsa

For a simple dev test, just accept all defaults when prompted. This should create two
files in your ~/.ssh folder:
id_rsa     => this is the private key
id_rsa.pub

# Tip: enabling passwordless access to the Ubuntu boxes using the above keys
ssh-copy-id user@IP of the Ubuntu box

when prompted, enter the password. This should copy the public key to the remote box
to enable passwordless ssh. To verify, do a ssh again:

ssh user@IP

# Caveats
TBD

# How the deployer works?
*TBD*
