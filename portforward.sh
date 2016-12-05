#!/bin/sh

# make sure existing port forwards are killed first
docker exec deployer bash -c 'pgrep "kubectl" | while read p; do kill $p; done'

pf=""
for e in grafana:3000 prometheus:9090 kibana:5601 elasticsearch:9200; do
  s=$(echo $e | cut -d":" -f1)
  p=$(echo $e | cut -d":" -f2)
  echo Forwarding $s port $p
  docker exec -itd deployer kubectl port-forward $(docker exec deployer kubectl get pod -l project=$s -o=jsonpath='{.items..metadata.name}') $p

  # build the line to port forward
  pf="$pf-L $p:localhost:$p "
done

echo Forwarding dashboard port
docker exec -itd deployer kubectl proxy

echo "If you are running boot2docker, you may want to run the following from your host..."
machine=$(docker-machine ls --filter state=running --filter driver=virtualbox -q)
echo docker-machine ssh $machine $pf-L 8001:localhost:8001
#echo "Ports forwarded. Ctrl+C when you are done..."
#docker-machine ssh $machine $pf-L 8001:localhost:8001 read x
