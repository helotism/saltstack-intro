#!/usr/bin/env bash

while true; do
  read -p "Stop all containers? [Yn] " yn
  [ -z "$yn" ] && yn="y"
  case $yn in
    [Yy]* ) docker stop saltmaster;
            docker stop saltminion01;
            docker stop saltminion02;
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
            docker rm saltminion02;
            break;;
    [Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
  esac
done