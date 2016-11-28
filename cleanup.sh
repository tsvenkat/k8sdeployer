#!/bin/sh

./runplay.sh playbooks/undeploy.yml
docker rm -f deployer > /dev/null 2>&1
sudo rm -rf docker-machine-conf/*
[ -f inventory.dat ] && rm inventory.dat
[ -f env.dat ] && rm env.dat
sudo rm -rf helm_repo/*

