#!/usr/bin/env bash

docker build -q -t helotism/heftydoseofsalt-minimal:$(head -n 1 VERSION) -t helotism/heftydoseofsalt-minimal:latest -f docker/phusion-baseimage-16.0.4-minimal/Dockerfile docker/
docker build -q -t helotism/heftydoseofsalt-saltmaster-ubuntu:$(head -n 1 VERSION) -t helotism/heftydoseofsalt-saltmaster-ubuntu:latest -f docker/heftydoseofsalt-saltmaster-ubuntu/Dockerfile docker/
docker build -q -t helotism/heftydoseofsalt-saltminion-ubuntu:$(head -n 1 VERSION) -t helotism/heftydoseofsalt-saltminion-ubuntu:latest -f docker/heftydoseofsalt-saltminion-ubuntu/Dockerfile docker/
docker rmi -f $(docker images --filter "dangling=true" -q)

#-v $(pwd)/salt/assets/etc/salt:/etc/salt
docker run -d --hostname saltmaster --name saltmaster -p 4505:4505 -p 4506:4506 \
-v $(pwd)/salt/assets/etc/salt:/etc/salt \
-v $(pwd)/salt/assets/var/cache/salt:/var/cache/salt \
-v $(pwd)/salt/assets/var/log/salt:/var/log/salt \
-v $(pwd)/salt/assets/srv/salt:/srv/salt \
helotism/heftydoseofsalt-saltmaster:latest /sbin/my_init

docker run -d --hostname saltminion01 --name saltminion01 \
--link saltmaster:saltmaster \
helotism/heftydoseofsalt-saltminion-ubuntu:v0.5 /sbin/my_init

#exit 0
sleep 3
saltmasterIP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $( docker ps | grep saltmaster | awk {'print $1'}))
saltminion01IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $( docker ps | grep saltminion01 | awk {'print $1'}))
echo ${saltminion01IP}; sleep 2
ssh -i docker/assets/phusion-baseimage/insecure_key root@${saltmasterIP}

docker stop saltmaster
docker rm saltmaster
docker stop saltminion01
docker rm saltminion01

# curl -u "cprior" https://api.github.com/orgs/helotism/repos -d '{"name":"saltstack-intro","description":"Gut gewuerzt -- a hefty dose of salt","homepage":"http://www.helotism.de/","auto_init":"true","license_template":"mit","has_wiki":"true","has_issues":"true","has_downloads":"false"}'
# i="";for frml in users dnsmasq ; do echo $frml; git remote add remote${i}_${frml}-formula git@github.com:saltstack-formulas/${frml}-formula.git; git fetch remote${i}_${frml}-formula; git read-tree --prefix=salt/assets/srv/formulas/${frml}_formula -u remote${i}_${frml}-formula/master; done
# for i in $(docker images | grep helotism | awk 'BEGIN {OFS=":"} {print $1,$2}'); do docker rmi $i; done
