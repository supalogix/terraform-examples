#!/bin/bash

set -e -x

sudo apt-get update -y
sudo apt-get install -y python
sudo apt-get install -y docker.io
sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo docker run -p 5000:5000 -e REGISTRY_HTTP_SECRET=s3cr3t registry:2
