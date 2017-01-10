#!/usr/bin/env bash

docker ps --all --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'

#for c in saltmaster saltminion01 saltminion02 ;
#  do docker start $c;
#done
#
#exit 0

docker run -d --hostname saltmaster --name saltmaster -p 8888:8888 -p 4505:4505 -p 4506:4506 \
--network=heftydoseofsalt \
-v saltmaster-etc-salt:/etc/salt \
-v /var/cache/salt \
-v /var/log/salt \
-v $(pwd)/app/saltstack/assets/srv/salt:/srv/salt \
-v $(pwd)/app/saltstack/assets/srv/pillar:/srv/pillar \
-v $(pwd)/app/saltstack/assets/srv/formulas:/srv/formulas \
-v $(pwd)/data:/mnt/data \
helotism/heftydoseofsalt-saltmaster-ubuntu:latest /sbin/my_init

docker network connect bridge saltmaster 

docker run -d --hostname saltminion01 --name saltminion01 \
--network=heftydoseofsalt \
-v saltminion01-etc-salt:/etc/salt \
helotism/heftydoseofsalt-saltminion-ubuntu:latest /sbin/my_init

docker run -d --hostname saltminion02 --name saltminion02 \
--network=heftydoseofsalt \
-v saltminion02-etc-salt:/etc/salt \
helotism/heftydoseofsalt-saltminion-debian:latest 

exit 0

#/** 
#  * ----------------------------------------------------------------
#  * 
#  */

for c in saltmaster saltminion01 saltminion02; do

  isrunning=false

  while read dockercontainer; do
    set -- $dockercontainer
    #echo "$1 $2"
    if [ "$1" == "$c" ]; then
      #echo "$1 $2"
      if [[ "$2" =~ up|Up ]]; then
        isrunning=true;
      fi
    fi
  done < <( docker ps --all --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}' )

  if [ "$isrunning" = true ]; then
    #echo "is running ${c}"
    :
  else
    echo "must start ${c}"
    docker start ${c}
  fi

  unset $isrunning
done
