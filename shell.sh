#!/bin/sh

# build the deployer image first
./build.sh

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
       --entrypoint /bin/bash localhost/k8sdeployer

# exec into the container shell
docker exec -it deployer /bin/bash
