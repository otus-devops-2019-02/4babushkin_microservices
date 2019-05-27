#!/bin/bash
export GOOGLE_PROJECT=docker-239201

#test -n "$(docker-machine ls | grep docker-host)" || eval $(docker-machine env --unset)

#start machine
docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-disk-size 50 \
--google-zone europe-west1-b docker-host
#

docker-machine ls
eval $(docker-machine env docker-host)
docker-machine ls
