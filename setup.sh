#!/usr/bin/env bash
#/** 
#  * This script 
#  * 
#  * Copyright (c) 2016 Christian Prior
#  * Licensed under the MIT License. See LICENSE file in the project root for full license information.
#  * 
#  * Usage:
#  * 
#  * @TODO:
#  * 
#  */

set -o nounset #exit on undeclared variable

__DOCKERNETWORKNAME="heftydoseofsalt"

docker build -q -t helotism/heftydoseofsalt-minimal-ubuntu:$(head -n 1 VERSION) -t helotism/heftydoseofsalt-minimal-ubuntu:latest -f docker/phusion-baseimage-16.0.4-minimal/Dockerfile docker/
docker build -q -t helotism/heftydoseofsalt-saltmaster-ubuntu:$(head -n 1 VERSION) -t helotism/heftydoseofsalt-saltmaster-ubuntu:latest -f docker/heftydoseofsalt-saltmaster-ubuntu/Dockerfile docker/
docker build -q -t helotism/heftydoseofsalt-saltminion-ubuntu:$(head -n 1 VERSION) -t helotism/heftydoseofsalt-saltminion-ubuntu:latest -f docker/heftydoseofsalt-saltminion-ubuntu/Dockerfile docker/
docker rmi -f $(docker images --filter "dangling=true" -q)

isexisting=false
while read dockernetwork; do
  set -- $dockernetwork
  #echo $dockernetwork
  if [ "$2" == "$__DOCKERNETWORKNAME" ]; then isexisting=true; fi
done < <(docker network ls)
if [ "$isexisting" = false ]; then
  docker network create -d bridge --subnet 172.76.4.0/24 ${__DOCKERNETWORKNAME}
fi
unset $isexisting

docker run -d --hostname saltmaster --name saltmaster -p 4505:4505 -p 4506:4506 \
--network=heftydoseofsalt \
-v saltmaster-etc-salt:/etc/salt \
-v /var/cache/salt \
-v /var/log/salt \
-v $(pwd)/salt/assets/srv/salt:/srv/salt \
-v $(pwd)/salt/assets/srv/pillar:/srv/pillar \
-v $(pwd)/salt/assets/srv/formulas:/srv/formulas \
helotism/heftydoseofsalt-saltmaster-ubuntu:latest /sbin/my_init

docker network connect bridge saltmaster 

docker run -d --hostname saltminion01 --name saltminion01 \
--network=heftydoseofsalt \
-v saltminion01-etc-salt:/etc/salt \
helotism/heftydoseofsalt-saltminion-ubuntu:latest /sbin/my_init

#exit 0
sleep 3
saltmasterIP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $( docker ps | grep saltmaster | awk {'print $1'}))
saltminion01IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $( docker ps | grep saltminion01 | awk {'print $1'}))
echo ${saltmasterIP}; echo ${saltminion01IP}; sleep 2
ssh -i docker/assets/phusion-baseimage/insecure_key root@${saltmasterIP}

while true; do
  read -p "Stop all containers? [Yn] " yn
  [ -z "$yn" ] && yn="y"
  case $yn in
    [Yy]* ) docker stop saltmaster;
            docker stop saltminion01;
            break;;
    [Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
  esac
done
while true; do
  read -p "Delete all containers? [yN] " yn
  [ -z "$yn" ] && yn="n"
  case $yn in
    [Yy]* ) docker rm saltmaster;
            docker rm saltminion01;
            break;;
    [Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
  esac
done

#docker stop saltmaster
#docker rm saltmaster
#docker stop saltminion01
#docker rm saltminion01
#rm -rf /salt/assets/etc/salt/pki
# curl -u "cprior" https://api.github.com/orgs/helotism/repos -d '{"name":"saltstack-intro","description":"Gut gewuerzt -- a hefty dose of salt","homepage":"http://www.helotism.de/","auto_init":"true","license_template":"mit","has_wiki":"true","has_issues":"true","has_downloads":"false"}'
# i="";for frml in users dnsmasq ; do echo $frml; git remote add remote${i}_${frml}-formula git@github.com:saltstack-formulas/${frml}-formula.git; git fetch remote${i}_${frml}-formula; git read-tree --prefix=salt/assets/srv/formulas/${frml}_formula -u remote${i}_${frml}-formula/master; done
# for i in $(docker images | grep helotism | awk 'BEGIN {OFS=":"} {print $1,$2}'); do docker rmi $i; done
# docker network inspect heftydoseofsalt
# docker inspect saltmaster | grep -A 10 Mounts

exit 0