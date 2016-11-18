#!/bin/sh

cd /

# build the inventory.dat file first based on inventory.conf file
/scripts/build_inventory.py

cd playbooks
# check if resources are accessible first
ansible -i ../inventory.dat resources -m ping

# setup proxy on target nodes
grep use_proxy /inventory.yml | grep -q yes
[ $? -eq 0 ] && ansible-playbook -i ../inventory.dat proxy_setup.yml

# setup docker engine on target using docker-machine
ansible-playbook -i ../inventory.dat machine_setup.yml

[ $? -ne 0 ] && exit $?

# all set to bootstrap
ansible-playbook -i ../inventory.dat bootstrap.yml

# if all went well, the kubectl command should list something useful
echo "Kubernetes setup is complete"
echo "Nodes"
kubectl get no

echo "Pods"
kubectl get po --all-namespaces -o wide

echo "Create a namespace for logging"
kubectl create namespace logging

kubectl cluster-info

