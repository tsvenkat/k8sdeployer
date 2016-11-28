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

# delete local kubelet.conf
rm /playbooks/kubelet.conf > /dev/null 2>&1

# all set to bootstrap
ansible-playbook -i ../inventory.dat bootstrap.yml

# run devenv playbook to patch k8s and install helm repo
ansible-playbook -i ../inventory.dat devenv.yml

# if all went well, the kubectl command should list something useful
echo "Kubernetes setup is complete"
echo "Nodes"
kubectl get no

echo "Pods"
kubectl get po --all-namespaces -o wide

echo "Create a namespace for logging"
kubectl create namespace logging

kubectl cluster-info

# install the k8s dashboard
kubectl create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml

echo "[optional] install weave agents. Get token from: https://cloud.weave.works/ and replace below"
weave_token="$weave_token"
kubectl apply -f "https://cloud.weave.works/launch/k8s/weavescope.yaml?service-token=$weave_token"

# install required helm packages
# but need to wait till tiller is in a Running state
podname=$(kubectl get po -l name=tiller -n kube-system -o=jsonpath='{.items[].metadata.name}')
while [ $(kubectl get po -n kube-system $podname -o=jsonpath='{.status.phase}') != "Running" ]; do
  echo "waiting for $podname to be running..."
  sleep 5
done

sleep 5

# get elasticsearch package
helm fetch fabric8/elasticsearch --untar
# patch it to not use the persistentVolumeClaim
python -c "import yaml; d=yaml.load(open('./elasticsearch/templates/elasticsearch-deployment.yaml')); volume=d['spec']['template']['spec']['volumes'][0]; volume['emptyDir']={}; del volume['persistentVolumeClaim']; yaml.dump(d,open('./elasticsearch/templates/elasticsearch-deployment.yaml','w'),default_flow_style=False)"

# install the patched version
helm install -n es ./elasticsearch

# install kibana for log visualization
helm install -n kibana fabric8/kibana

# install fluentd for centralized logging
helm install -n fluentd fabric8/fluentd

# port forward the dashboard
kubectl proxy --port=8081 &

# port forward the Elasticsearch and Kibana pods
es_pod_name=$(kubectl get po -l project=elasticsearch -o=jsonpath='{.items[0].metadata.name}')
kibana_pod_name=$(kubectl get po -l project=kibana -o=jsonpath='{.items[0].metadata.name}')

while [ $(kubectl get po $es_pod_name -o=jsonpath='{.status.phase}') != "Running" ]; do
  echo "waiting for $es_pod_name to be running..."
  sleep 5
done

while [ $(kubectl get po $kibana_pod_name -o=jsonpath='{.status.phase}') != "Running" ]; do
  echo "waiting for $kibana_pod_name to be running..."
  sleep 5
done

kubectl port-forward $es_pod_name 9200 &
kubectl port-forward $kibana_pod_name 5601 &

kubectl get po --all-namespaces -o wide
echo 'Congratulations. Have fun with your cluster!'
echo 'If you are using boot2docker, to access your services, do the following from your host'
echo 'docker-machine ssh <machine-running-deployer> -L 9200:localhost:9200 -L 5601:localhost:5601 -L 8081:localhost:8081'
echo 'Dashboard: http://localhost:8081/ui'
echo 'Kibana: http://localhost:5601'
echo 'Weave cloud: https://cloud.weave.works/org/floating-waterfall-43'
