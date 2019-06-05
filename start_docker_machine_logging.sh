#!/bin/bash
export GOOGLE_PROJECT=docker-239201

#test -n "$(docker-machine ls | grep docker-host)" || eval $(docker-machine env --unset)

#start machine 
docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-open-port 5601/tcp \
    --google-open-port 9292/tcp \
    --google-open-port 9411/tcp \
    --google-zone europe-west1-b logging

#

sleep 5
eval $(docker-machine env logging)
docker-machine ls

docker-machine ip logging

