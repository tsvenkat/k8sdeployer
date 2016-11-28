#!/bin/sh

# check if using Vagrant
grep -q "^\s*use_vagrant:\s*yes" inventory.yml
if [ \( $? -eq 0 \) -a \( -f "$(which vagrant)" \) ]; then
  # check if vagrant up needs to be called
  vagrant status | grep "not created" -q
  [ $? -eq 0 ] && echo "Using vagrant to bring up VMs..." && vagrant up
fi

# build the deployer image first
./build.sh

# setup a docker container that abstracts the steps required to
# setup a k8s cluster
docker run -itd --name deployer -h DEPLOYER\
       --network=host\
       -v /var/run/docker.sock:/var/run/docker.sock\
       -v `pwd`/docker-machine-conf:/root/.docker/machine\
       -v `pwd`/ssh_config:/root/.ssh\
       -v `pwd`/inventory.yml:/inventory.yml\
       -v `pwd`/inventory.dat:/inventory.dat\
       -v `pwd`/playbooks:/playbooks\
       -v `pwd`/scripts:/scripts\
       -v `pwd`/helm_repo:/root/.helm/repository\
       -e KUBECONFIG=/playbooks/kubelet.conf\
       --env-file env.dat\
       --entrypoint /bin/bash localhost/k8sdeployer

[ $? -ne 0 ] && exit $?

docker exec -it deployer /scripts/deploy.sh
