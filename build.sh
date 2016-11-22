#!/bin/sh

# delete the old local image
#docker rmi localhost/k8sdeployer > /dev/null 2>&1

# build the deployer image first
docker build --build-arg http_proxy --build-arg https_proxy --build-arg no_proxy -t localhost/k8sdeployer .

# this files gets writtent to by the deployer
# if the file doesn't exist, docker bind mount will treat it as a folder
# hence touching the file here
touch ./inventory.dat
