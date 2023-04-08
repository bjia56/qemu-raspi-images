#!/bin/bash

# debconf is being held by some process, should be ok to kill it?
sudo fuser -v -k /var/cache/debconf/config.dat

sudo apt update
sudo apt -y upgrade

# install docker
curl -fsSL https://get.docker.com | sudo sh