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

docker build    -t helotism/heftydoseofsalt-minimal-ubuntu:$(head -n 1 VERSION)    -t helotism/heftydoseofsalt-minimal-ubuntu:latest    -f tec/docker/phusion-baseimage-16.0.4-minimal/Dockerfile  tec/docker/
docker build    -t helotism/heftydoseofsalt-saltmaster-ubuntu:$(head -n 1 VERSION) -t helotism/heftydoseofsalt-saltmaster-ubuntu:latest -f tec/docker/heftydoseofsalt-saltmaster-ubuntu/Dockerfile tec/docker/
docker build    -t helotism/heftydoseofsalt-saltminion-ubuntu:$(head -n 1 VERSION) -t helotism/heftydoseofsalt-saltminion-ubuntu:latest -f tec/docker/heftydoseofsalt-saltminion-ubuntu/Dockerfile tec/docker/
docker build    -t helotism/heftydoseofsalt-saltminion-debian:$(head -n 1 VERSION) -t helotism/heftydoseofsalt-saltminion-debian:latest -f tec/docker/heftydoseofsalt-saltminion-debian/Dockerfile tec/docker/
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

exit 0

#/** 
#  * ----------------------------------------------------------------
#  * 
#  */

#saltmasterIP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $( docker ps | grep saltmaster | awk {'print $1'}))
#ssh -i docker/assets/phusion-baseimage/insecure_key root@${saltmasterIP}
#for c in saltmaster saltminion02 saltminion01; do docker stop $c; docker rm $c; done
#rm -rf app/saltstack/assets/etc/salt/pki
# curl -u "cprior" https://api.github.com/orgs/helotism/repos -d '{"name":"saltstack-intro","description":"Gut gewuerzt -- a hefty dose of salt","homepage":"http://www.helotism.de/","auto_init":"true","license_template":"mit","has_wiki":"true","has_issues":"true","has_downloads":"false"}'
# i="";for frml in users dnsmasq ; do echo $frml; git remote add remote${i}_${frml}-formula git@github.com:saltstack-formulas/${frml}-formula.git; git fetch remote${i}_${frml}-formula; git read-tree --prefix=salt/assets/srv/formulas/${frml}_formula -u remote${i}_${frml}-formula/master; done
# for i in $(docker images | grep helotism | awk 'BEGIN {OFS=":"} {print $1,$2}'); do docker rmi $i; done
# docker network inspect heftydoseofsalt
# docker inspect saltmaster | grep -A 10 Mounts
# docker-compose build
exit 0