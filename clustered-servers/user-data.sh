#!/bin/bash

set -e -x

sudo apt-get update -y
sudo apt-get install -y python
sudo apt-get install -y docker.io
sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
cd /home/ubuntu
git init
echo "${private_key}" > private_key
git remote add origin https://github.com/supalogix/node-hello-world.git
git pull origin ${git_tag}
sudo docker-compose up -d