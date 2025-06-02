#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export UCF_FORCE_CONFFOLD=1
export UCF_FORCE_CONFDEF=1

# system update
apt update
apt -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" -y upgrade

# install docker
apt -y install ca-certificates curl gnupg
mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -a -G docker pi
systemctl status docker.service
