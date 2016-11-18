#!/bin/sh

# build the deployer image first
docker build --build-arg http_proxy --build-arg https_proxy --build-arg no_proxy -t uncle/k8sdeployer .

# setup a docker container that abstracts the steps required to
# setup a k8s cluster
docker run -itd --name deployer -h DEPLOYER\
       -v /var/run/docker.sock:/var/run/docker.sock\
       -v `pwd`/docker-machine-conf:/root/.docker/machine\
       -v `pwd`/ssh_config:/root/.ssh\
       -v `pwd`/inventory.yml:/inventory.yml\
       -v `pwd`/playbooks:/playbooks\
       -v `pwd`/scripts:/scripts\
       -e KUBECONFIG=/kubelet.conf\
       --entrypoint /scripts/deploy.sh uncle/k8sdeployer
