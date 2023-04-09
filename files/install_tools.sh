#!/bin/bash

curl google.com
curl archive.raspberrypi.org
curl deb.debian.org
curl get.docker.com

apt update
apt -y upgrade

# install docker
curl -fsSL https://get.docker.com | sh