#!/bin/sh

# build the deployer image first
docker build --build-arg http_proxy --build-arg https_proxy --build-arg no_proxy -t uncle/k8sdeployer .
