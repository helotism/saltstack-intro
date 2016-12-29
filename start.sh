#!/usr/bin/env bash

docker build -t salt-intro docker
docker rmi -f $(docker images --filter "dangling=true" -q)

#-v $(pwd)/salt/assets/etc/salt:/etc/salt
docker run -d --hostname saltmaster --name saltmaster -p 4505:4505 -p 4506:4506 -v $(pwd)/salt/assets/var/cache/salt:/var/cache/salt -v $(pwd)/salt/assets/var/log/salt:/var/log/salt -v $(pwd)/salt/assets/srv/salt:/srv/salt salt-intro /sbin/my_init

IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $( docker ps | grep saltmaster | awk {'print $1'}))
ssh -i docker/assets/phusion-baseimage/insecure_key root@${IP}

docker stop saltmaster
docker rm saltmaster
