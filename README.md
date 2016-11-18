# k8sdeployer [![Build Status](https://travis-ci.org/tsvenkat/k8sdeployer.svg?branch=master)](https://travis-ci.org/tsvenkat/k8sdeployer)
Setup k8s on existing Ubuntu 16.04 boxes using kubeadm, docker and ansible

# Introduction
The main intent of this project is to setup a docker based development environment
for Kubernetes with existing Ubuntu 16.04 installations.
It uses the newer kubeadm based deployment. Assuming the following workflow for
a k8s developer:

1. git clone https://github.com/tsvenkat/k8sdeployer
2. ./build.sh
   This should build the image localhost/k8sdeployer which does all the hard
   work of setting up an environment to deploy kubernetes on the specified
   Ubuntu 16.X nodes (details below)
3. Edit the inventory.yml file and update the fields marked with <SETME
4. Copy the id_rsa and id_rsa.pub files needed to communicate with the Ubuntu
   boxes under the ssh_config folder
5. Run the deploy_k8s.sh script to bring up a container with name "deployer" that
   runs a script to setup the k8s deployment and tail the logs. Once this is done,
   it shows the Kubernetes cluster details and the developer could then:

    *docker exec -it deployer /bin/bash*
   to shell into the container and start using it. As a convenience, the deployer
   is configured with kubectl and helm tools 

# Requirements
* Git
* Docker (tested with v1.12.3)
* Linux shell

# How the deployer works?
*TBD*
