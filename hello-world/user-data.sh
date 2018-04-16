#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y python
cd /home/ubuntu
echo "Hello World" > /home/ubuntu/index.html
sudo python -m SimpleHTTPServer 80