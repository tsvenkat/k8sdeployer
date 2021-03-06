#!/bin/sh

docker rm -f deployer_shell > /dev/null 2>&1

./build.sh

# setup a docker container that abstracts the steps required to
# setup a k8s cluster
docker run -it --name deployer_shell -h DEPLOYER\
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
       --entrypoint ansible-playbook localhost/k8sdeployer -i /inventory.dat $@
