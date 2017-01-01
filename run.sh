#!/usr/bin/env bash

docker ps --all --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'

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

