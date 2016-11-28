#!/bin/sh

# delete the old local image
#docker rmi localhost/k8sdeployer > /dev/null 2>&1

# build the deployer image first
docker build --build-arg http_proxy --build-arg https_proxy --build-arg no_proxy -t localhost/k8sdeployer .

# this files gets written to by the deployer
# if the file doesn't exist, docker bind mount will treat it as a folder
# hence touching the file here
touch ./inventory.dat

# create an env file for passing proxy info to the container
>env.dat  # truncate the file first
grep -q "^\s*use_proxy:\s*yes" inventory.yml
if [ $? -eq 0 ]; then
  echo http_proxy=$(grep http_proxy inventory.yml | cut -d":" -f2- | tr -d ' ') >> env.dat
  echo https_proxy=$(grep https_proxy inventory.yml | cut -d":" -f2- | tr -d ' ') >> env.dat
  echo no_proxy=$(grep no_proxy inventory.yml | cut -d":" -f2- | tr -d ' ') >> env.dat
fi
echo weave_token=$(grep weave_token inventory.yml | cut -d":" -f2 | tr -d ' ') >> env.dat
