#!/bin/bash

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-compose mc 


sudo mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs
sudo cp /tmp/docker-compose.yml /srv/gitlab/docker-compose.yml
cd /srv/gitlab/
export EXTR_IP=$(curl ifconfig.io)
sudo sed -i 's/<YOUR-VM-IP>/'$EXTR_IP'/g' docker-compose.yml
echo $EXTR_IP
sudo usermod -aG docker $USER

