#!/bin/sh

echo  forward grafana port
docker exec -itd deployer kubectl port-forward $(docker exec deployer kubectl get pod -l project=grafana -o=jsonpath='{.items..metadata.name}') 3000

echo forward prometheus port
docker exec -itd deployer kubectl port-forward $(docker exec deployer kubectl get pod -l project=prometheus -o=jsonpath='{.items..metadata.name}') 9090

echo forward kibana port
docker exec -itd deployer kubectl port-forward $(docker exec deployer kubectl get pod -l project=kibana -o=jsonpath='{.items..metadata.name}') 5601

echo forward elasticsearch port
docker exec -itd deployer kubectl port-forward $(docker exec deployer kubectl get pod -l project=elasticsearch -o=jsonpath='{.items..metadata.name}') 9200

echo forward dashboard port
docker exec -itd deployer kubectl proxy

echo "If you are running boot2docker, you may want to run the following from your host..."
echo "docker-machine ssh <machine> -L 3000:localhost:3000 -L 9090:localhost:9090 -L 5601:localhost:5601 -L 9200:localhost:9200 -L 8001:localhost:8001"
