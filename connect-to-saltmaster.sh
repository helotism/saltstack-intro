#!/usr/bin/env bash

ssh -L 28888:localhost:8888 -i tec/docker/assets/phusion-baseimage/insecure_key root@172.76.4.2 -t screen -RD

